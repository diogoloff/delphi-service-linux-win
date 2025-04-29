unit unControlWindows;

interface

uses Winapi.Windows;

type
  TConsoleBreak = reference to procedure;

var
  FConsoleBreak : TConsoleBreak;

procedure SetarConsoleCtrlHandler;

implementation

function ConsoleCtrlHandler(dwCtrlType: DWORD): BOOL; stdcall;
begin
  case dwCtrlType of
    CTRL_C_EVENT, CTRL_BREAK_EVENT, CTRL_CLOSE_EVENT, CTRL_LOGOFF_EVENT, CTRL_SHUTDOWN_EVENT:
      begin
        Writeln('Encerrando aplicação...');

        if (Assigned(FConsoleBreak)) then
            FConsoleBreak;

        Result := True;
      end;
  else
    Result := False;
  end;
end;

procedure SetarConsoleCtrlHandler;
begin
  // Configura o handler para capturar Ctrl + C
  if not SetConsoleCtrlHandler(@ConsoleCtrlHandler, True) then
  begin
    Writeln('Erro ao configurar handler!');
    Exit;
  end;
end;

end.
