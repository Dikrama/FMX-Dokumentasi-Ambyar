unit uGoFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Objects,
  System.ImageList, FMX.ImgList, System.Rtti, FMX.Grid.Style, FMX.ScrollBox,
  FMX.Grid,FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListBox, FMX.Ani, System.Threading,
  FMX.ListView.Adapters.Base, FMX.ListView, FMX.LoadingIndicator, FMX.Memo, FMX.Edit,
  {$IFDEF ANDROID}
    Androidapi.Helpers, FMX.Platform.Android, System.Android.Service, System.IOUtils,
    FMX.Helpers.Android, Androidapi.JNI.PlayServices, Androidapi.JNI.Os,
  {$ENDIF}
  System.Generics.Collections;


type
  TFrameClass = class of TFrame;

procedure fnCallFrame(AParent: TLayout; FrameClass: TFrameClass);
procedure createFrame;

var
  genFrame: TFrame;

implementation

uses frMain, frHome, frLoading, uFunc;

procedure fnCallFrame(AParent: TLayout; FrameClass: TFrameClass);
begin
  genFrame := FrameClass.Create(FMain);
  genFrame.Parent := AParent;
  genFrame.Align := TAlignLayout.Contents;
end;

procedure createFrame;
begin
  try
    fnCallFrame(FMain.loFrame, frLoading.TFLoading);
    FLoading := TFLoading(genFrame);
    FLoading.Visible := False;

    fnCallFrame(FMain.loFrame, frHome.TFHome);
    FHome := TFHome(genFrame);
    FHome.Visible := False;
  except

  end;
end;

end.

