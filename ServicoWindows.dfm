object MinhaAplicacao: TMinhaAplicacao
  OldCreateOrder = False
  OnCreate = ServiceCreate
  AllowPause = False
  DisplayName = 'MinhaAplicacao'
  OnContinue = ServiceContinue
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 150
  Width = 215
end
