unit frHome;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.Edit, System.Rtti,
  FMX.Grid.Style, FMX.Grid, FMX.ScrollBox, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, System.Threading;

type
  TFHome = class(TFrame)
    Label1: TLabel;
    edNama: TEdit;
    vsMain: TVertScrollBox;
    edKelas: TEdit;
    Label2: TLabel;
    edAlamat: TEdit;
    Alamat: TLabel;
    stgMain: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    btnSimpan: TCornerButton;
    btnClear: TCornerButton;
    btnHapus: TCornerButton;
    background: TRectangle;
    nHTTP: TNetHTTPClient;
    procedure btnSimpanClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure stgMainCellClick(const Column: TColumn; const Row: Integer);
    procedure btnHapusClick(Sender: TObject);
  private
    transID : String;
    { Private declarations }
    procedure setFrame;
    procedure fnLoadData;
    procedure fnSimpan(stat : String);
    procedure fnClearText;
  public
    { Public declarations }
    procedure FirstShow;
    procedure ReleaseFrame;
  end;

var
  FHome : TFHome;

implementation

{$R *.fmx}

uses frMain, uFunc, uMain, uRest;

{ TFTemp }

const
  UBAH = 'ubah';        //parameter di dalam API
  SIMPAN = 'simpan';    //parameter di dalam API
  HAPUS = 'hapus';    //parameter di dalam API

procedure TFHome.btnClearClick(Sender: TObject);
begin
  fnClearText;
end;

procedure TFHome.btnHapusClick(Sender: TObject);
begin
  TTask.Run(procedure begin
    fnSimpan(HAPUS);
  end).Start;
end;

procedure TFHome.btnSimpanClick(Sender: TObject);
var
  str : String;
begin
  if btnSimpan.Text = 'Simpan' then
    str := SIMPAN
  else
    str := UBAH;

  TTask.Run(procedure begin
    fnSimpan(str);
  end).Start;
end;

procedure TFHome.FirstShow;
begin
  setFrame;

  TTask.Run(procedure begin //uses System.Threading
    sleep(idle);
    fnLoadData;
  end).Start;
end;

procedure TFHome.fnClearText;
begin
  transID := '';

  edNama.Text := '';
  edKelas.Text := '';
  edAlamat.Text := '';

  btnSimpan.Text := 'Simpan';
end;

procedure TFHome.fnLoadData;
var
  req : String;
  arr : TStringArray;
  bar : Integer;
begin
  fnLoadLoading(True);
  try
    req := 'loadData';

    arr := fnGetJSON(nHTTP, req);  //load data dengan API

    if arr[0, 0] = 'null' then begin
      fnShowE(arr[1, 0]);
      Exit
    end;

    TThread.Synchronize(nil, procedure begin
      fnClearString(stgMain);
      stgMain.RowCount := Length(arr[0]);
    end);

    for bar := 0 to Length(arr[0]) - 1 do begin
      TThread.Synchronize(nil, procedure begin
        stgMain.Cells[0, bar] := arr[1, bar];
        stgMain.Cells[1, bar] := arr[2, bar];
        stgMain.Cells[2, bar] := arr[3, bar];
        stgMain.Cells[3, bar] := arr[0, bar];

        Application.ProcessMessages;
      end);
    end;

  finally
    fnLoadLoading(False);
  end;
end;

procedure TFHome.fnSimpan(stat: String);
var
  req : String;
  arr : TStringArray;
  par : TStringList;
begin
  fnLoadLoading(True);
  try
    par := TStringList.Create;
    try
      if stat = HAPUS then begin
        par.AddPair('id', transID);
      end else begin
        if stat = UBAH then
          par.AddPair('id', transID);

        par.AddPair('nm', edNama.Text);
        par.AddPair('kelas', edKelas.Text);
        par.AddPair('alamat', edAlamat.Text);
      end;

      req := stat;
      arr := fnPostJSON(nHTTP, req, par);

    finally
      par.DisposeOf;
      par := nil;
    end;

    if arr[0, 0] = 'null' then begin
      fnShowE(arr[1, 0]);
      Exit
    end;

    fnShowE(arr[1, 0]);

    TThread.Synchronize(nil, procedure begin
      fnClearText;
    end);

    fnLoadData;
  finally
    fnLoadLoading(False);
  end;
end;

procedure TFHome.ReleaseFrame;
begin
  DisposeOf;
end;

procedure TFHome.setFrame;
var
  wi, he, pad : Single;
  i: Integer;
begin
  wi := FHome.Width;
  he := FHome.Height;

  pad := 8;

  fnGetClient(FHome, vsMain);
  fnGetClient(FHome, background);

  for i := 0 to vsMain.Content.ControlsCount - 1 do begin
    fnSetPosXY(
      TControl(vsMain.Content.Controls[i]),
        pad,
        TControl(vsMain.Content.Controls[i]).Position.Y,
        wi - (pad * 2),
        TControl(vsMain.Content.Controls[i]).Height);
  end;

  fnSetPosXY(
    stgMain,
      pad,
      fnGetPosYDown(btnHapus, pad),
      wi - (pad * 2),
      vsMain.Height - (fnGetPosYDown(btnHapus, pad) + (pad * 2)));
end;

procedure TFHome.stgMainCellClick(const Column: TColumn; const Row: Integer);
begin
  transID := stgMain.Cells[3, Row];
  btnSimpan.Text := 'Ubah';

  edNama.Text :=  stgMain.Cells[0, Row];
  edKelas.Text :=  stgMain.Cells[1, Row];
  edAlamat.Text :=  stgMain.Cells[2, Row];
end;

end.
