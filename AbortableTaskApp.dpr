program AbortableTaskApp;

uses
  Vcl.Forms,
  AbortableTask.Async.RunnerList in 'AbortableTask.Async.RunnerList.pas',
  AbortableTask.Result in 'AbortableTask.Result.pas',
  AbortableTask.Async.Runner in 'AbortableTask.Async.Runner.pas',
  AbortableTask.Async.SharedData in 'AbortableTask.Async.SharedData.pas',
  AbortableTask.Tools in 'AbortableTask.Tools.pas',
  AbortableTask.Types in 'AbortableTask.Types.pas',
  AbortableTask.Async.Worker in 'AbortableTask.Async.Worker.pas',
  ExampleTask in 'ExampleTask.pas',
  Helper.Async in 'Helper.Async.pas',
  unAbortableTask in 'unAbortableTask.pas' {fmMain},
  unFraTask in 'unFraTask.pas' {fraTask: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
