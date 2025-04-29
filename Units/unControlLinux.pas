unit unControlLinux;

interface

uses System.SysUtils, Posix.Signal, Posix.Base, Posix.Unistd;

type
  TLinuxSignal = (Termination, Reload, User1, User2);
  TSignalProc = reference to procedure (lSignal: TLinuxSignal);

const // openlog() option
  LOG_PID    = $01;
  LOG_CONS   = $02;
  LOG_ODELAY = $04;
  LOG_NDELAY = $08;
  LOG_NOWAIT = $10;
  LOG_PERROR = $20;

const // openlog() facility
  LOG_KERN        =  0 shl 3;
  LOG_USER        =  1 shl 3;
  LOG_MAIL        =  2 shl 3;
  LOG_DAEMON      =  3 shl 3;
  LOG_AUTH        =  4 shl 3;
  LOG_SYSLOG      =  5 shl 3;
  LOG_LPR         =  6 shl 3;
  LOG_NEWS        =  7 shl 3;
  LOG_UUCP        =  8 shl 3;
  LOG_CRON        =  9 shl 3;
  LOG_AUTHPRIV    = 10 shl 3;
  LOG_FTP         = 11 shl 3;
  LOG_LOCAL0      = 16 shl 3;
  LOG_LOCAL1      = 17 shl 3;
  LOG_LOCAL2      = 18 shl 3;
  LOG_LOCAL3      = 19 shl 3;
  LOG_LOCAL4      = 20 shl 3;
  LOG_LOCAL5      = 21 shl 3;
  LOG_LOCAL6      = 22 shl 3;
  LOG_LOCAL7      = 23 shl 3;
  LOG_NFACILITIES = 24;
  LOG_FACMASK     = $03f8;
  INTERNAL_NOPRI  = $10;
  INTERNAL_MARK   = LOG_NFACILITIES shl 3;

const // setlogmask() level
  LOG_EMERG   = 0;
  LOG_ALERT   = 1;
  LOG_CRIT    = 2;
  LOG_ERR     = 3;
  LOG_WARNING = 4;
  LOG_NOTICE  = 5;
  LOG_INFO    = 6;
  LOG_DEBUG   = 7;
  LOG_PRIMASK = $07;

  procedure HandleSignals(lSigNum: Integer); cdecl;

  procedure openlog(ident: MarshaledAString; option: LongInt; facility: LongInt); cdecl;
  external libc name _PU + 'openlog';

  procedure closelog; cdecl;
  external libc name _PU + 'closelog';

  procedure syslog(priority: LongInt; _format: MarshaledAString; args: array of const); cdecl;
  external libc name _PU + 'syslog';

  function sd_notify(AUnSetEnvironment : LongInt; AState: MarshaledAString): LongInt; cdecl;
  external 'libsystemd.so' name _PU + 'sd_notify';

var
  FSignalProc : TSignalProc;

  const EXIT_FAILURE = 1;
  const ROOT_DIR = '/';

  procedure AplicacaoPronta;
  procedure EncerrarAplicacao;
  procedure LogInfo(const AMessage: string);

implementation

procedure HandleSignals(lSigNum: Integer);
begin
  case lSigNum of
    SIGTERM:
    begin
      if (Assigned(FSignalProc)) then
          FSignalProc(TLinuxSignal.Termination);
    end;
    SIGHUP:
    begin
      if (Assigned(FSignalProc)) then
          FSignalProc(TLinuxSignal.Reload);
    end;
    SIGUSR1:
    begin
      if (Assigned(FSignalProc)) then
          FSignalProc(TLinuxSignal.User1);
    end;
    SIGUSR2:
    begin
      if (Assigned(FSignalProc)) then
          FSignalProc(TLinuxSignal.User2);
    end;
  end;
end;

procedure InterceptarSignalsHandler;
begin
  signal(SIGHUP,  HandleSignals);
  signal(SIGTERM, HandleSignals);
  signal(SIGUSR1, HandleSignals);
  signal(SIGUSR2, HandleSignals);
end;

procedure AbrirLog;
begin
  openlog(nil, LOG_PID or LOG_NDELAY, LOG_DAEMON);
end;

procedure FecharLog;
begin
  closelog;
end;

procedure LogSistema(APriority: LongInt; const AFormat: string);
var
  LMarshaller: TMarshaller;
  str: MarshaledAString;
begin
  str := LMarshaller.AsAnsi(AFormat, CP_UTF8).ToPointer;
  syslog(APriority, str, []);
end;

procedure LogInfo(const AMessage: string);
begin
  LogSistema(LOG_INFO, AMessage);
end;

procedure CriarArquivoPID;
var
    lsPath : String;
    liPID : Integer;

    lFile : Text;
begin
  liPID := getpid();

  LogInfo('Criando Arquivo PID ' + IntToStr(liPID));

  if (liPID > 0) then
  begin
    ChDir(ROOT_DIR);

    lsPath := '/run/' + ExtractFileName(ParamStr(0)) + '.pid';

    try
      if (FileExists(lsPath)) then
        deleteFile(lsPath);

      Assign(lFile, lsPath);
      rewrite(lFile);
      writeln(lFile, UTF8Encode(IntToStr(liPID)));
      close(lFile);
    except
      on E : Exception do
      begin
          LogInfo('Erro: ' + E.Message);
      end;
    end;
  end;
end;

procedure RemoverArquivoPID;
var
  lsPath : String;
begin
  try
    ChDir(ROOT_DIR);

    lsPath := '/run/' + ExtractFileName(ParamStr(0)) + '.pid';

    if (FileExists(lsPath)) then
        deleteFile(lsPath);
  except
    on E : Exception do
    begin
        LogInfo('Erro: ' + E.Message);
    end;
  end;
end;

procedure AplicacaoPronta;
begin
  InterceptarSignalsHandler;
  AbrirLog;
  sd_notify(0, 'READY=1');
  CriarArquivoPID;
end;

procedure EncerrarAplicacao;
begin
  RemoverArquivoPID;
  FecharLog;
end;

end.
