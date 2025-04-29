program ServicoLinux;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  {$IFDEF LINUX}
  {$ELSE}
  unControlWindows in 'Units\unControlWindows.pas',
  {$ENDIF }
  unAplicacao in 'Units\unAplicacao.pas',
  unControlLinux in 'Units\unControlLinux.pas';

begin
  {$IFDEF DEBUG}
    ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  try
    {$IFDEF LINUX}
      FSignalProc :=
        procedure (lSingnal : TLinuxSignal)
        begin
          case lSingnal of

            Termination:
              begin
                LogInfo('Termination Signal ' + TimeToStr(Now));
                PararAplicacao;
              end;

            Reload:
              begin
                LogInfo('Reload Signal ' + TimeToStr(Now));
              end;

            User1:
              begin
                LogInfo('User1 Signal ' + TimeToStr(Now));
                PararAplicacao;
              end;

            User2:
              begin
                LogInfo('User2 Signal ' + TimeToStr(Now));
              end;
          end;
        end;

      AplicacaoPronta;
    {$ELSE}
      FConsoleBreak :=
        procedure
        begin
          PararAplicacao;
        end;

      SetarConsoleCtrlHandler;
    {$ENDIF}

    RodarAplicacao;
  except
    on E: Exception do
    begin
      {$IFDEF LINUX}
        LogInfo(E.ClassName + ': ' + E.Message);
        EncerrarAplicacao;
        Halt(EXIT_FAILURE);
      {$ELSE}
        Writeln(E.ClassName, ': ', E.Message);
        Writeln('Precione qualquer tecla para continuar...');
        Readln;
      {$ENDIF}
    end;
  end;

  {$IFDEF LINUX}
    EncerrarAplicacao;
  {$ENDIF}
end.
