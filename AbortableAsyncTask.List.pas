unit AbortableAsyncTask.List;

interface

uses System.Classes, System.SysUtils, System.Generics.Collections, System.SyncObjs, AbortableAsyncTask.Types;

type
  TAbortableAsyncTaskList = class(TInterfacedObject, IAbortableAsyncTaskList)
  strict private
    fCritialSection: TCriticalSection;
    fDict: TDictionary<IAbortableAsyncTaskRunnerBase, Byte>;
    fRequestAbortToAllEvent: TLightweightEvent;
    procedure Add(const aRunner: IAbortableAsyncTaskRunnerBase);
    procedure Remove(const aRunner: IAbortableAsyncTaskRunnerBase);
    function GetCount: Integer;
    function First: IAbortableAsyncTaskRunnerBase;
    procedure RequestAbortToAllAndWait;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses Helper.Async;

{ TAbortableAsyncTaskList }

constructor TAbortableAsyncTaskList.Create;
begin
  inherited Create;
  fCritialSection := TCriticalSection.Create;
  fRequestAbortToAllEvent := TLightweightEvent.Create;
  fDict := TDictionary<IAbortableAsyncTaskRunnerBase, Byte>.Create;
end;

destructor TAbortableAsyncTaskList.Destroy;
begin
  fDict.Free;
  fRequestAbortToAllEvent.Free;
  fCritialSection.Free;
  inherited;
end;

function TAbortableAsyncTaskList.First: IAbortableAsyncTaskRunnerBase;
begin
  fCritialSection.Enter;
  try
    Result := nil;
    if fDict.Count > 0 then
      Result := fDict.Keys.ToArray[0];
  finally
    fCritialSection.Leave;
  end;
end;

function TAbortableAsyncTaskList.GetCount: Integer;
begin
  fCritialSection.Enter;
  try
    Result := fDict.Count;
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAbortableAsyncTaskList.Add(const aRunner: IAbortableAsyncTaskRunnerBase);
begin
  if fRequestAbortToAllEvent.IsSet then
    Exit;

  fCritialSection.Enter;
  try
    fDict.AddOrSetValue(aRunner, 0);
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAbortableAsyncTaskList.Remove(const aRunner: IAbortableAsyncTaskRunnerBase);
begin
  if fRequestAbortToAllEvent.IsSet then
    Exit;

  fCritialSection.Enter;
  try
    fDict.Remove(aRunner);
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAbortableAsyncTaskList.RequestAbortToAllAndWait;
var
  lWaitObjects: TArray<THandle>;
  i: Integer;
  lRunner: IAbortableAsyncTaskRunnerBase;
begin
  fRequestAbortToAllEvent.SetEvent;
  try
    fCritialSection.Enter;
    try
      SetLength(lWaitObjects, fDict.Count);
      i := 0;
      for lRunner in fDict.Keys do
      begin
        lWaitObjects[i] := lRunner.WorkerThreadHandle;
        Inc(i);
        lRunner.RequestAbort;
      end;
      WaitForWhileProcessMessages(lWaitObjects, TWaitForKind.WaitForAll);
      fDict.Clear;
    finally
      fCritialSection.Leave;
    end;
  finally
    fRequestAbortToAllEvent.ResetEvent;
  end;
end;

end.
