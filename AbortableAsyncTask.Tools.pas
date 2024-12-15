unit AbortableAsyncTask.Tools;

interface

uses System.SysUtils, AbortableAsyncTask.Types;

type
  TAbortableAsyncTaskProgressBegin = reference to procedure(const aMaxWorkCount: Int64);
  TAbortableAsyncTaskProgressEnd = reference to procedure();
  TAbortableAsyncTaskProgressStep = reference to procedure(const aWorkCount: Int64; var aAbortRequested: Boolean);

  TAbortableAsyncTaskProgressIndicator = class(TInterfacedObject, IAbortableAsyncTaskProgressIndicator)
  strict private
    fProgressBegin: TAbortableAsyncTaskProgressBegin;
    fProgressEnd: TAbortableAsyncTaskProgressEnd;
    fProgressStep: TAbortableAsyncTaskProgressStep;
    procedure ProgressBegin(const aMaxWorkCount: Int64);
    procedure ProgressEnd();
    procedure ProgressStep(const aWorkCount: Int64; var aAbortRequested: Boolean);
  public
    constructor Create(const aProgressBegin: TAbortableAsyncTaskProgressBegin;
      const aProgressEnd: TAbortableAsyncTaskProgressEnd;
      const aProgressStep: TAbortableAsyncTaskProgressStep);
  end;

implementation

{ TAbortableAsyncTaskProgressIndicator }

constructor TAbortableAsyncTaskProgressIndicator.Create(const aProgressBegin: TAbortableAsyncTaskProgressBegin;
  const aProgressEnd: TAbortableAsyncTaskProgressEnd; const aProgressStep: TAbortableAsyncTaskProgressStep);
begin
  inherited Create;
  fProgressBegin := aProgressBegin;
  fProgressEnd := aProgressEnd;
  fProgressStep := aProgressStep;
end;

procedure TAbortableAsyncTaskProgressIndicator.ProgressBegin(const aMaxWorkCount: Int64);
begin
  fProgressBegin(aMaxWorkCount);
end;

procedure TAbortableAsyncTaskProgressIndicator.ProgressEnd;
begin
  fProgressEnd();
end;

procedure TAbortableAsyncTaskProgressIndicator.ProgressStep(const aWorkCount: Int64; var aAbortRequested: Boolean);
begin
  fProgressStep(aWorkCount, aAbortRequested);
end;

end.
