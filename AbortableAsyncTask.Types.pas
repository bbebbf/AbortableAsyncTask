unit AbortableAsyncTask.Types;

interface

uses System.Classes, System.SysUtils, Helper.Async;

type
  IAbortableAsyncProgressIndicator<K> = interface
    ['{0400CBCD-A1E6-4A5C-A527-79FDA318ED1B}']
    procedure ProgressBegin(const aKey: K; const aMaxWorkCount: Int64);
    procedure ProgressEnd(const aKey: K);
    procedure ProgressStep(const aKey: K; const aWorkCount: Int64);
  end;

  IAbortableAsyncTask<T, K> = interface
    ['{E3702C3E-51AD-4EB7-9FB8-E816C039163F}']
    function GetTaskName: string;
    procedure ExchangeProgressIndicator(out aTaskProgressIndicator: IAbortableAsyncProgressIndicator<K>;
      const aThreadProgressIndicator: IAbortableAsyncProgressIndicator<K>);
    procedure ExceptionOccurred(const aException: Exception);
    function ExecuteTask: T;
  end;

  TAbortableAsyncTaskTaskFinishedState = (Unknown, Succeeded, Aborted, Excepted, WaitForError);

  IAbortableAsyncTaskResultBase = interface
    ['{E292DE06-D067-4795-8274-2B299C189DF1}']
    function GetFinishedState: TAbortableAsyncTaskTaskFinishedState;
    function GetExceptionMessage: string;
    function GetExceptionClass: TClass;

    property FinishedState: TAbortableAsyncTaskTaskFinishedState read GetFinishedState;
    property ExceptionMessage: string read GetExceptionMessage;
    property ExceptionClass: TClass read GetExceptionClass;
  end;

  IAbortableAsyncTaskResult<T> = interface(IAbortableAsyncTaskResultBase)
    ['{CDF7CFF2-AAD8-48A1-A570-89060D31BD87}']
    function GetResult: T;
    property &Result: T read GetResult;
  end;

  IAbortableAsyncTaskRunnerBase = interface
    ['{C7817F76-53F6-4D41-BBEB-9663AC4DB3BD}']
    function IsRunning: Boolean;
    procedure RequestAbort;
    function WaitForTask: IAbortableAsyncTaskResultBase;
    function GeTAbortableAsyncTaskWorkerThreadHandle: THandle;
    function GetRunnerObject: TObject;
    function GetFinishedState: TAbortableAsyncTaskTaskFinishedState;
    function GetExceptionMessage: string;
    function GetExceptionClass: TClass;

    property WorkerThreadHandle: THandle read GeTAbortableAsyncTaskWorkerThreadHandle;
    property RunnerObject: TObject read GetRunnerObject;
    property FinishedState: TAbortableAsyncTaskTaskFinishedState read GetFinishedState;
    property ExceptionMessage: string read GetExceptionMessage;
    property ExceptionClass: TClass read GetExceptionClass;
  end;

  IAbortableAsyncTaskRunner<T> = interface(IAbortableAsyncTaskRunnerBase)
    ['{65763F41-A120-4B42-8FB5-472D594956E8}']

    function WaitForTaskResult: IAbortableAsyncTaskResult<T>;
    function GetTaskResult: T;

    property TaskResult: T read GetTaskResult;
  end;

  IAbortableAsyncTaskList = interface
    ['{BB2609C0-A2EB-4D1E-B6DE-65EF877F84B5}']
    procedure Add(const aRunner: IAbortableAsyncTaskRunnerBase);
    procedure Remove(const aRunner: IAbortableAsyncTaskRunnerBase);
    function GetCount: Integer;
    function First: IAbortableAsyncTaskRunnerBase;
    procedure RequestAbortToAllAndWait;
    property Count: Integer read GetCount;
  end;

  IAbortableAsyncTaskSharedData<T> = interface
    ['{885D45BF-03D1-4732-B851-B34EC3EAB18A}']
    function GetExceptionMessage: string;
    function GetExceptionClass: TClass;
    function GetAbortRequested: Boolean;
    procedure RequestAbort;
    procedure SetSucceededState(const aTaskResult: T);
    procedure SetAbortedState(const aException: Exception);
    procedure SetExceptedState(const aException: Exception);
    function GetTaskResult: T;
    function GetFinishedState: TAbortableAsyncTaskTaskFinishedState;
    property AbortRequested: Boolean read GetAbortRequested;
    property FinishedState: TAbortableAsyncTaskTaskFinishedState read GetFinishedState;
    property TaskResult: T read GetTaskResult;
    property ExceptionMessage: string read GetExceptionMessage;
    property ExceptionClass: TClass read GetExceptionClass;
  end;

  EAbortableAsyncTaskAbort = class(EAbort);

implementation

end.
