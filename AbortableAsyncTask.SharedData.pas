unit AbortableAsyncTask.SharedData;

interface

uses System.SysUtils, System.SyncObjs, AbortableAsyncTask.Types;

type
  TAbortableAsyncTaskSharedData<T> = class(TInterfacedObject, IAbortableAsyncTaskSharedData<T>)
  strict private
    fCritialSection: TCriticalSection;
    fAbortRequested: Boolean;
    fTaskResult: T;
    fFinishedState: TAbortableAsyncTaskTaskFinishedState;
    fExceptionMessage: string;
    fExceptionClass: TClass;
    function GetExceptionMessage: string;
    function GetExceptionClass: TClass;
    function GetAbortRequested: Boolean;
    function GetTaskResult: T;
    function GetFinishedState: TAbortableAsyncTaskTaskFinishedState;
    procedure RequestAbort;
    procedure SetSucceededState(const aTaskResult: T);
    procedure SetAbortedState(const aException: Exception);
    procedure SetExceptedState(const aException: Exception);
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TAbortableAsyncTaskSharedData<T> }

constructor TAbortableAsyncTaskSharedData<T>.Create;
begin
  inherited Create;
  fCritialSection := TCriticalSection.Create;
  fExceptionClass := Self.ClassType; // Self.ClassType is used like a null implementation here.
end;

destructor TAbortableAsyncTaskSharedData<T>.Destroy;
begin
  fCritialSection.Free;
  inherited;
end;

function TAbortableAsyncTaskSharedData<T>.GetFinishedState: TAbortableAsyncTaskTaskFinishedState;
begin
  fCritialSection.Enter;
  try
    Result := fFinishedState;
  finally
    fCritialSection.Leave;
  end;
end;

function TAbortableAsyncTaskSharedData<T>.GetTaskResult: T;
begin
  fCritialSection.Enter;
  try
    Result := fTaskResult;
  finally
    fCritialSection.Leave;
  end;
end;

function TAbortableAsyncTaskSharedData<T>.GetAbortRequested: Boolean;
begin
  fCritialSection.Enter;
  try
    Result := fAbortRequested;
  finally
    fCritialSection.Leave;
  end;
end;

function TAbortableAsyncTaskSharedData<T>.GetExceptionClass: TClass;
begin
  fCritialSection.Enter;
  try
    Result := fExceptionClass;
  finally
    fCritialSection.Leave;
  end;
end;

function TAbortableAsyncTaskSharedData<T>.GetExceptionMessage: string;
begin
  fCritialSection.Enter;
  try
    Result := fExceptionMessage;
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAbortableAsyncTaskSharedData<T>.RequestAbort;
begin
  fCritialSection.Enter;
  try
    fAbortRequested := True;
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAbortableAsyncTaskSharedData<T>.SetSucceededState(const aTaskResult: T);
begin
  fCritialSection.Enter;
  try
    fTaskResult := aTaskResult;
    fFinishedState := TAbortableAsyncTaskTaskFinishedState.Succeeded;
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAbortableAsyncTaskSharedData<T>.SetAbortedState(const aException: Exception);
begin
  fCritialSection.Enter;
  try
    fExceptionMessage := aException.Message;
    fExceptionClass := aException.ClassType;
    fFinishedState := TAbortableAsyncTaskTaskFinishedState.Aborted;
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAbortableAsyncTaskSharedData<T>.SetExceptedState(const aException: Exception);
begin
  fCritialSection.Enter;
  try
    fExceptionMessage := aException.Message;
    fExceptionClass := aException.ClassType;
    fFinishedState := TAbortableAsyncTaskTaskFinishedState.Excepted;
  finally
    fCritialSection.Leave;
  end;
end;

end.
