unit ExampleTask;

interface

uses System.SysUtils, AbortableAsyncTask.Types;

type
  TExampleTask = class(TInterfacedObject, IAbortableAsyncTask)
  strict private
    fProgressIndicator: IAbortableAsyncTaskProgressIndicator;
    fAsyncProgressProcs: IAbortableAsyncThreadProgressIndicator;
    function GetTaskName: string;
    procedure GetTaskProgressIndicator(out aTaskProgressIndicator: IAbortableAsyncTaskProgressIndicator);
    procedure SetAsyncProgressIntf(const aAsyncProgressIntf: IAbortableAsyncThreadProgressIndicator);
    procedure GetAbortRequestedProc(out aAbortRequestedProc: TAbortableAsyncTaskAbortRequestedProc);
    procedure ExecuteTask;
  public
    constructor Create(const aProgressIndicator: IAbortableAsyncTaskProgressIndicator);
  end;

implementation

uses System.Classes, System.IOUtils;

{ TExampleTask }

constructor TExampleTask.Create(const aProgressIndicator: IAbortableAsyncTaskProgressIndicator);
begin
  inherited Create;
  fProgressIndicator := aProgressIndicator;
end;

procedure TExampleTask.ExecuteTask;
var lStream: TStream;
  lWriter: TTextWriter;
begin
  lStream := TFileStream.Create(TPath.Combine(ExtractFilePath(ParamStr(0)), 'ExampleTask.txt'),
    fmCreate or fmOpenWrite or fmShareDenyWrite);
  try
    lWriter := TStreamWriter.Create(lStream, TEncoding.UTF8);
    try
      const lMax = 120;
      fAsyncProgressProcs.ProgressBegin(lMax);
      for var i := 1 to lMax do
      begin
        fAsyncProgressProcs.ProgressStep(i);
        lWriter.Write(IntToStr(i) + sLineBreak);
        Sleep(500);
      end;
    finally
      fAsyncProgressProcs.ProgressEnd;
      lWriter.Write('Done.');
      lWriter.Free;
    end;
  finally
    lStream.Free;
  end;
end;

procedure TExampleTask.GetAbortRequestedProc(out aAbortRequestedProc: TAbortableAsyncTaskAbortRequestedProc);
begin

end;

function TExampleTask.GetTaskName: string;
begin
  Result := ClassName;
end;

procedure TExampleTask.GetTaskProgressIndicator(out aTaskProgressIndicator: IAbortableAsyncTaskProgressIndicator);
begin
  aTaskProgressIndicator := fProgressIndicator;
end;

procedure TExampleTask.SetAsyncProgressIntf(const aAsyncProgressIntf: IAbortableAsyncThreadProgressIndicator);
begin
  fAsyncProgressProcs := aAsyncProgressIntf;
end;

end.
