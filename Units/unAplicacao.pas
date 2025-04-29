unit unAplicacao;

interface

uses System.SysUtils, System.Classes, System.IOUtils;

var
  FPathAplicao : String;
  FAplicacaoRodando : Boolean;

  procedure RodarAplicacao;
  procedure PararAplicacao;

implementation

procedure GerarLog(lsMsg: String);
var
  lsArquivo : String;
begin
  {$IFNDEF SERVICO}
    Writeln(lsMsg);
  {$ENDIF}

  lsArquivo := FPathAplicao + 'app.log';

  try
    TFile.AppendAllText(lsArquivo, TimeToStr(Now) + ':' + lsMsg + sLineBreak, TEncoding.UTF8);
  except
  end;
end;

procedure RodarAplicacao;
var
  liIteracao: Integer;
  //lLista : TStringList;
begin
  FPathAplicao := ExtractFilePath(ParamStr(0));
  GerarLog('Aplica��o Iniciada');
  FAplicacaoRodando := True;

  liIteracao := 0;
  while FAplicacaoRodando do
  begin
    //lLista := TStringList.Create;
    //FreeAndNil(lLista);

    inc(liIteracao);
    GerarLog('Itera��o: ' + IntToStr(liIteracao));
    Sleep(1000);
  end;

  GerarLog('Aplica��o Parada');
end;

procedure PararAplicacao;
begin
  GerarLog('Parando Aplica��o');
  FAplicacaoRodando := False;
end;

end.
