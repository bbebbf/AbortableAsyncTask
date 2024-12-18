program AbortableAsyncTaskApp;

uses
  Vcl.Forms,
  unAbortableAsyncTask in 'unAbortableAsyncTask.pas' {fmMain},
  AbortableAsyncTask.Runner in 'AbortableAsyncTask.Runner.pas',
  ExampleTask in 'ExampleTask.pas',
  AbortableAsyncTask.Types in 'AbortableAsyncTask.Types.pas',
  AbortableAsyncTask.Tools in 'AbortableAsyncTask.Tools.pas',
  AbortableAsyncTask.List in 'AbortableAsyncTask.List.pas',
  Helper.Async in 'Helper.Async.pas',
  AbortableAsyncTask.Result in 'AbortableAsyncTask.Result.pas',
  AbortableAsyncTask.SharedData in 'AbortableAsyncTask.SharedData.pas',
  AbortableAsyncTask.WorkerThread in 'AbortableAsyncTask.WorkerThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
