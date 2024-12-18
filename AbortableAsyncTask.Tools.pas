unit AbortableAsyncTask.Tools;

interface

uses System.SysUtils, AbortableAsyncTask.Types;

type
  TAbortableAsyncTaskProgressBegin<K> = reference to procedure(const aKey: K; const aMaxWorkCount: Int64);
  TAbortableAsyncTaskProgressEnd<K> = reference to procedure(const aKey: K);
  TAbortableAsyncTaskProgressStep<K> = reference to procedure(const aKey: K; const aWorkCount: Int64);

  TAbortableAsyncTaskProgressIndicator<K> = class(TInterfacedObject, IAbortableAsyncProgressIndicator<K>)
  strict private
    fProgressBegin: TAbortableAsyncTaskProgressBegin<K>;
    fProgressEnd: TAbortableAsyncTaskProgressEnd<K>;
    fProgressStep: TAbortableAsyncTaskProgressStep<K>;
    procedure ProgressBegin(const aKey: K; const aMaxWorkCount: Int64);
    procedure ProgressEnd(const aKey: K);
    procedure ProgressStep(const aKey: K; const aWorkCount: Int64);
  public
    constructor Create(const aProgressBegin: TAbortableAsyncTaskProgressBegin<K>;
      const aProgressEnd: TAbortableAsyncTaskProgressEnd<K>;
      const aProgressStep: TAbortableAsyncTaskProgressStep<K>);
  end;

implementation

{ TAbortableAsyncTaskProgressIndicator<K> }

constructor TAbortableAsyncTaskProgressIndicator<K>.Create(const aProgressBegin: TAbortableAsyncTaskProgressBegin<K>;
  const aProgressEnd: TAbortableAsyncTaskProgressEnd<K>;
  const aProgressStep: TAbortableAsyncTaskProgressStep<K>);
begin
  inherited Create;
  fProgressBegin := aProgressBegin;
  fProgressEnd := aProgressEnd;
  fProgressStep := aProgressStep;
end;

procedure TAbortableAsyncTaskProgressIndicator<K>.ProgressBegin(const aKey: K; const aMaxWorkCount: Int64);
begin
  fProgressBegin(aKey, aMaxWorkCount);
end;

procedure TAbortableAsyncTaskProgressIndicator<K>.ProgressEnd(const aKey: K);
begin
  fProgressEnd(aKey);
end;

procedure TAbortableAsyncTaskProgressIndicator<K>.ProgressStep(const aKey: K; const aWorkCount: Int64);
begin
  fProgressStep(aKey, aWorkCount);
end;

end.
