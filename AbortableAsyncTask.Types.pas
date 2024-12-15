unit AbortableAsyncTask.Types;

interface

type
  TAbortableAsyncTaskAbortRequestedProc = reference to procedure(var aAbortRequested: Boolean);

  IAbortableAsyncTaskProgressIndicator = interface
    ['{7A91979B-AA2A-4F5E-86E1-0DB567AFC579}']
    procedure ProgressBegin(const aMaxWorkCount: Int64);
    procedure ProgressEnd();
    procedure ProgressStep(const aWorkCount: Int64; var aAbortRequested: Boolean);
  end;

  IAbortableAsyncThreadProgressIndicator = interface
    ['{0400CBCD-A1E6-4A5C-A527-79FDA318ED1B}']
    procedure ProgressBegin(const aMaxWorkCount: Int64);
    procedure ProgressEnd();
    procedure ProgressStep(const aWorkCount: Int64);
  end;

  IAbortableAsyncTask = interface
    ['{E3702C3E-51AD-4EB7-9FB8-E816C039163F}']
    function GetTaskName: string;
    procedure GetTaskProgressIndicator(out aTaskProgressIndicator: IAbortableAsyncTaskProgressIndicator);
    procedure SetAsyncProgressIntf(const aAsyncProgressIntf: IAbortableAsyncThreadProgressIndicator);
    procedure GetAbortRequestedProc(out aAbortRequestedProc: TAbortableAsyncTaskAbortRequestedProc);
    procedure ExecuteTask;
  end;

implementation

end.
