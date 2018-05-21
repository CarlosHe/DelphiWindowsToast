unit FMX.Toast.Windows;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, FMX.Types, FMX.TextLayout,
  FMX.Controls, FMX.Graphics, FMX.Ani, FMX.Forms, FMX.Layouts,
  System.Generics.Collections, DateUtils;

type
  TWindowsToastDuration = (ToastDurationLengthShort, ToastDurationLengthLong);

  TWindowsToast = class(TControl)
  private
    FBackgroundSize: TSize;
    FFloatAnimationOpacity: TFloatAnimation;
    FText: string;
    FFont: TFont;
    FFillText: TBrush;
    FFillBackground: TBrush;
    FOnFinishToast: TNotifyEvent;
    FIsStarted: Boolean;
    FDuration: TWindowsToastDuration;
    FThreadDuration: TThread;
    procedure SetText(const Value: String);
    procedure SetFillText(const Value: TBrush);
    procedure SetFillBackground(const Value: TBrush);
    procedure SetOnFinishToast(const Value: TNotifyEvent);
    procedure SetIsStarted(const Value: Boolean);
    procedure SetDuration(const Value: TWindowsToastDuration);
    { Private declarations }
  protected
    { Protected declarations }
    procedure DoFinishToast(Sender: TObject);
    property FillText: TBrush read FFillText write SetFillText;
    property FillBackground: TBrush read FFillBackground write SetFillBackground;
    property Duration: TWindowsToastDuration read FDuration write SetDuration;
    procedure Paint; override;
    procedure DoTextChanged(Sender: TObject);
    procedure RecalcToastHeight;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Start;
  published
    { Published declarations }
    property Align;
    property Anchors;
    property Width;
    property Height;
    property Size;
    property Enabled;
    property Padding;
    property Margins;
    property Opacity;
    property ClipChildren;
    property ClipParent;
    property HitTest;
    property Visible;
    property Locked;
    property Position;
    property Text: String read FText write SetText;
    property OnClick;
    property OnDblClick;
    property OnPainting;
    property OnPaint;
    property OnResize;
    property OnResized;
    property OnFinishToast: TNotifyEvent read FOnFinishToast write SetOnFinishToast;
    property IsStarted: Boolean read FIsStarted write SetIsStarted;
  end;

  TWindowsToastDialog = class(TCustomScrollBox)
  private
    FToastList: TObjectList<TWindowsToast>;
    { private declarations }
  protected
    { protected declarations }
    procedure DoFinishToast(Sender: TObject);
    function GetDefaultStyleLookupName: string; override;
    function DoCalcContentBounds: TRectF; override;
    procedure Paint; override;
    procedure DoUpdateAniCalculations(const AAniCalculations: TScrollCalculations); override;
  public
    { public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Content;
    procedure MakeText(AText: string; const ADuration: TWindowsToastDuration = TWindowsToastDuration.ToastDurationLengthShort;
      ABackgroundColor: TAlphaColor = $FF525252; ATextColor: TAlphaColor = $FFFFFFFF);
  published
    { published declarations }
    property Align;
    property Anchors;
    property ClipParent;
    property Cursor;
    property DisableMouseWheel;
    property Height;
    property Locked;
    property Margins;
    property Opacity;
    property Padding;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property TouchTargetExpansion;
    property Visible;
    property Width;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Material Design', [TWindowsToastDialog]);
end;

{ TWindowsToast }

constructor TWindowsToast.Create(AOwner: TComponent);
begin
  inherited;
  FIsStarted := False;
  FFont := TFont.Create;
  FFont.Size := 14;
  FFont.Family := 'Roboto';

  FFillText := TBrush.Create(TBrushKind.Solid, $FFFFFFFF);
  FFillBackground := TBrush.Create(TBrushKind.Solid, $FF525252);
  FFloatAnimationOpacity := TFloatAnimation.Create(Self);
  AddObject(FFloatAnimationOpacity);
  Width := 300;
  Height := 30;

  FBackgroundSize := TSize.Create(270, 30);

  HitTest := False;
end;

destructor TWindowsToast.Destroy;
begin
  FFont.Free;
  FFillText.Free;
  FFillBackground.Free;
  FFloatAnimationOpacity.Free;
  if IsStarted then
  begin
     FThreadDuration.Terminate;
  end;
  inherited;
end;

procedure TWindowsToast.DoFinishToast(Sender: TObject);
begin
  if Assigned(FOnFinishToast) then
    FOnFinishToast(Self);
end;

procedure TWindowsToast.DoTextChanged(Sender: TObject);
begin
  RecalcToastHeight;
  Repaint;
end;

procedure TWindowsToast.Paint;
var
  FillTextRect: TRectF;
begin
  inherited;
  FillTextRect := TRectF.Create(Width / 2 - FBackgroundSize.Width / 2, 15, Width / 2 + FBackgroundSize.Width / 2, FBackgroundSize.Height - 15);
  // Desenha primeiro o fundo...
  Canvas.Fill.Assign(FFillBackground);
  Canvas.FillRect(TRectF.Create((Width / 2 - FBackgroundSize.Width / 2) - 15, 0, (Width / 2 + FBackgroundSize.Width / 2) + 15,
    FBackgroundSize.Height), FBackgroundSize.Height / 2, FBackgroundSize.Height / 2, [TCorner.TopLeft, TCorner.TopRight, TCorner.BottomLeft,
    TCorner.BottomRight], Opacity, TCornerType.Round);
  // Depois desenha o texto...
  Canvas.Fill.Assign(FFillText);
  Canvas.FillText(FillTextRect, FText, True, Opacity * 0.87 / 1, [], TTextAlign.Center, TTextAlign.Leading);
end;

procedure TWindowsToast.RecalcToastHeight;
var
  MeasureTextRect: TRectF;
begin
  // Calcula o tamanho do texto
  MeasureTextRect := TRectF.Create(0, 0, FBackgroundSize.Width, Screen.Height);
  Canvas.Fill.Assign(FFillText);
  Canvas.Font.Assign(FFont);
  Canvas.MeasureText(MeasureTextRect, FText, True, [], TTextAlign.Center, TTextAlign.Leading);
  FBackgroundSize.Height := Round(MeasureTextRect.Height) + 30;
  Height := FBackgroundSize.Height;
  if MeasureTextRect.Width < 250 then
    FBackgroundSize.Width := Round(MeasureTextRect.Width) + 30;
end;

procedure TWindowsToast.SetDuration(const Value: TWindowsToastDuration);
begin
  FDuration := Value;
end;

procedure TWindowsToast.SetFillBackground(const Value: TBrush);
begin
  FFillBackground := Value;
end;

procedure TWindowsToast.SetFillText(const Value: TBrush);
begin
  FFillText := Value;
end;

procedure TWindowsToast.SetIsStarted(const Value: Boolean);
begin
  FIsStarted := Value;
end;

procedure TWindowsToast.SetOnFinishToast(const Value: TNotifyEvent);
begin
  FOnFinishToast := Value;
end;

procedure TWindowsToast.SetText(const Value: String);
var
  OldText: string;
begin
  OldText := FText;
  FText := Value;
  if OldText <> FText then
    DoTextChanged(Self);
end;

procedure TWindowsToast.Start;
begin
  FIsStarted := True;
  FFloatAnimationOpacity.PropertyName := 'Opacity';
  FFloatAnimationOpacity.Duration := 0.5;
  FFloatAnimationOpacity.StartValue := 0;
  FFloatAnimationOpacity.StopValue := 1;

  FThreadDuration := TThread.CreateAnonymousThread(
    procedure
    var
      LDateTime: TDateTime;
      LNow: TDateTime;
    begin

      TThread.Synchronize(nil,
        procedure
        begin
          FFloatAnimationOpacity.Enabled := True;
        end);
      LDateTime := Now();
      LNow := Now();

      case FDuration of
        ToastDurationLengthShort:
          while (SecondsBetween(LNow, LDateTime) <= 3) and (not FThreadDuration.CheckTerminated) do
          begin
            LNow := Now();
          end;
        ToastDurationLengthLong:
          while (SecondsBetween(LNow, LDateTime) <= 6) and (not FThreadDuration.CheckTerminated) do
          begin
            LNow := Now();
          end;
      end;

      TThread.Synchronize(nil,
        procedure
        begin
          FFloatAnimationOpacity.Enabled := False;
          FFloatAnimationOpacity.StartValue := 1;
          FFloatAnimationOpacity.StopValue := 0;
          FFloatAnimationOpacity.OnFinish := DoFinishToast;
          FFloatAnimationOpacity.Enabled := True;
        end);

    end);

  FThreadDuration.Start;
end;

{ TWindowsToastDialog }

constructor TWindowsToastDialog.Create(AOwner: TComponent);
begin
  inherited;
  ShowScrollBars := False;
  FToastList := TObjectList<TWindowsToast>.Create;
  HitTest := False;
  Content.Locked := True;
  Content.Enabled := False;
  Enabled := False;
end;

procedure TWindowsToastDialog.Paint;
begin
  inherited;
  if (csDesigning in ComponentState) and not Locked then
    DrawDesignBorder(DesignBorderColor or TAlphaColorRec.Alpha, DesignBorderColor);
end;

destructor TWindowsToastDialog.Destroy;
begin
  FToastList.Clear;
  FreeAndNil(FToastList);
  inherited;
end;

function TWindowsToastDialog.DoCalcContentBounds: TRectF;
begin
  if (Content <> nil) and (ContentLayout <> nil) then
    Content.Width := ContentLayout.Width;
  Result := inherited DoCalcContentBounds;
  if ContentLayout <> nil then
    Result.Width := ContentLayout.Width;
end;

procedure TWindowsToastDialog.DoFinishToast(Sender: TObject);
var
  LWindowsToast: TWindowsToast;
begin
  LWindowsToast := Sender as TWindowsToast;
  LWindowsToast.Parent := nil;
  FToastList.Remove(LWindowsToast);
  // Self.Content.Repaint;
end;

procedure TWindowsToastDialog.DoUpdateAniCalculations(const AAniCalculations: TScrollCalculations);
begin
  inherited DoUpdateAniCalculations(AAniCalculations);
  AAniCalculations.TouchTracking := AAniCalculations.TouchTracking - [ttHorizontal];
end;

function TWindowsToastDialog.GetDefaultStyleLookupName: string;
begin
  Result := 'scrollboxstyle';
end;

procedure TWindowsToastDialog.MakeText(AText: string; const ADuration: TWindowsToastDuration; ABackgroundColor, ATextColor: TAlphaColor);
var
  LWindowsToast: TWindowsToast;
begin
  LWindowsToast := TWindowsToast.Create(nil);
  FToastList.Add(LWindowsToast);
  Content.AddObject(LWindowsToast);

  LWindowsToast.Opacity := 0;
  LWindowsToast.FillBackground.Color := ABackgroundColor;
  LWindowsToast.FillText.Color := ATextColor;
  LWindowsToast.Text := AText;
  LWindowsToast.Duration := ADuration;
  LWindowsToast.OnFinishToast := DoFinishToast;
  LWindowsToast.Margins.Bottom := 5;

  // LWindowsToast.Position.Y := Self.Content.Height - LWindowsToast.Height - (30);
  LWindowsToast.Position.X := Self.Content.Width / 2 - LWindowsToast.Width / 2;
  LWindowsToast.Position.Y := Content.Width;
  LWindowsToast.Align := TAlignLayout.Bottom;
  LWindowsToast.Start;

end;

end.
