unit ServicoWindows;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.SvcMgr, unAplicacao;

type
  TMinhaAplicacao = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceCreate(Sender: TObject);
  private
    { Private declarations }
    FAplicacaoParada : Boolean;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  MinhaAplicacao: TMinhaAplicacao;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  MinhaAplicacao.Controller(CtrlCode);
end;

function TMinhaAplicacao.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TMinhaAplicacao.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
  while not Terminated do
  begin
      if (FAplicacaoParada) then
          Break;

      ServiceThread.ProcessRequests(True);
  end;
end;

procedure TMinhaAplicacao.ServiceCreate(Sender: TObject);
begin
  FAplicacaoParada := False;
end;

procedure TMinhaAplicacao.ServiceStart(Sender: TService; var Started: Boolean);
begin
  FAplicacaoParada := False;

  TThread.CreateAnonymousThread(
    procedure
    begin
      RodarAplicacao;

      FAplicacaoParada := True;
    end
  ).Start;
end;

procedure TMinhaAplicacao.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  PararAplicacao;
end;

end.
