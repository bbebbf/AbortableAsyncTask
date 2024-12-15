program AbortableAsyncTaskApp;

uses
  Vcl.Forms,
  unAbortableAsyncTask in 'unAbortableAsyncTask.pas' {fmMain},
  AbortableAsyncTask in 'AbortableAsyncTask.pas',
  ExampleTask in 'ExampleTask.pas',
  AbortableAsyncTask.Types in 'AbortableAsyncTask.Types.pas',
  AbortableAsyncTask.Tools in 'AbortableAsyncTask.Tools.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
