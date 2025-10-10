(* Delphi program
   Show available power states
   ===========================

   © Dr. J. Rathlev, D-24222 Schwentinental (pb(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - August 2025
   last modified: August 2025

   *)

program PowerCaps;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  WinApi.Windows,
  WinApi.Messages,
  WinApiUtils,
  StringUtils,
  ExtSysUtils;

const
  nl = 30;

  WakeModes : array [TSystemPowerState] of string = (
    'Unspecified','Standby S0','Standby S1','Standby S2','Standby S3',
    'Hibernate','Shut down','');

function BoolToAvail (b : boolean) : string;
begin
  if b then Result:='Available' else Result:='Missing';
  end;

function GetMinSec(seconds : integer) : string;
begin
  if integer(seconds)>=0 then Result:=IntTosTr(seconds div 60)+':'+IntTosTr(seconds mod 60)+' m:s'
  else Result:='Unknown';
  end;

function WakeModeToStr (wm : TSystemPowerState) : string;
begin
  Result:=WakeModes[wm];
  end;

var
  pwc : TSystemPowerCapabilities;
  pws : TSystemPowerStatus;
  s : string;
  i : integer;
begin
  writeln('System power management hardware resources and capabilities');
  writeln('===========================================================');
  if GetPowerCapabilities(pwc) then begin
    with pwc do begin
      writeln(ExtSp('Standby mode S0:',nl),BoolToAvail(AoAc));
      writeln(ExtSp('Standby mode S1:',nl),BoolToAvail(SystemS1));
      writeln(ExtSp('Standby mode S2:',nl),BoolToAvail(SystemS2));
      writeln(ExtSp('Standby mode S3:',nl),BoolToAvail(SystemS3));
      writeln(ExtSp('Standby mode S4:',nl),BoolToAvail(SystemS4));
      writeln(ExtSp('Standby mode S5:',nl),BoolToAvail(SystemS5));
      writeln(ExtSp('Hybrid sleep mode:',nl),BoolToAvail(FastSystemS4));
      writeln(ExtSp('Display dimming:',nl),BoolToAvail(VideoDimPresent));
      writeln(ExtSp('Hibernation file:',nl),BoolToAvail(HiberFilePresent));
      writeln;
      writeln(ExtSp('System batteries:',nl),BoolToAvail(SystemBatteriesPresent));
//      if SystemBatteriesPresent then begin
        writeln(ExtSp('Short-term batteries (UPS):',nl),BoolToAvail(BatteriesAreShortTerm));
        for i:=0 to 2 do with BatteryScale[i] do begin
          writeln('  Battery ',i+1);
          writeln(ExtSp('    Granularity:',nl),Granularity,' mWh');
          writeln(ExtSp('    Capacity:',nl),Capacity,' mWh');
          end;
//        end;
      writeln;
      writeln(ExtSp('Power button:',nl),BoolToAvail(PowerButtonPresent));
      writeln(ExtSp('Sleep button:',nl),BoolToAvail(SleepButtonPresent));
      writeln(ExtSp('Lid switch:',nl),BoolToAvail(LidPresent));
      writeln;
      writeln(ExtSp('Wake support:',nl),BoolToAvail(FullWake));
      writeln(ExtSp('Wake alarm:',nl),BoolToAvail(WakeAlarmPresent));
      writeln;
      writeln('Lowest sleep state for wake event:');
      writeln(ExtSp('AC power:',nl),WakeModeToStr(AcOnLineWake));
      writeln(ExtSp('Lid switch:',nl),WakeModeToStr(SoftLidWake));
      writeln(ExtSp('Real time clock:',nl),WakeModeToStr(RtcWake));
      writeln(ExtSp('Minimum state for wake event:',nl),WakeModeToStr(MinDeviceWakeState));
      writeln(ExtSp('Default system power state:',nl),WakeModeToStr(DefaultLowLatencyWake));
      writeln;
      writeln(ExtSp('APM BIOS support:',nl),BoolToAvail(ApmPresent));
      writeln(ExtSp('UPS support:',nl),BoolToAvail(UpsPresent));
      writeln;
      writeln(ExtSp('Thermal control:',nl),BoolToAvail(ThermalControl));
      writeln(ExtSp('Processor throttling:',nl),BoolToAvail(ProcessorThrottle));
      if ProcessorThrottle then begin
        writeln(ExtSp('  Minimum throttling:',nl),IntToStr(ProcessorMinThrottle),'%');
        writeln(ExtSp('  Maximum throttling:',nl),IntToStr(ProcessorMaxThrottle),'%');
        end;
      writeln;
      writeln(ExtSp('Power removal of fixed disks:',nl),BoolToAvail(DiskSpinDown));
      writeln;
      end;
    end
  else begin
    writeln (SystemErrorMessage(GetLastError));
    end;
  writeln('System power status');
  writeln('===================');
  if GetSystemPowerStatus(pws) then begin
    with pws do begin
      case ACLineStatus of
      0 : s:='Offline';
      1 : s:='Online';
      else s:='Unknown';
        end;
      writeln(ExtSp('AC line status:',nl),s);
      case BatteryFlag of
      1 : s:='High';
      2 : s:='Low';
      4 : s:='Critical';
      8 : s:='Charging';
      128 : s:='No system battery';
      else s:='Unknown';
        end;
      writeln(ExtSp('Battery status:',nl),s);
      if BatteryFlag<=8 then begin // battery available
        if BatteryLifePercent<=100 then s:=IntToStr(BatteryLifePercent)+' %'
        else s:='Unknown';
        writeln(ExtSp('Remaining charge:',nl),s);
        if Reserved1=1 then s:='On' else s:='Off';  // SystemStatusFlag since Win 10
        writeln(ExtSp('Battery saver:',nl),s);
        writeln(ExtSp('Remaining life time:',nl),GetMinSec(BatteryLifeTime));
        writeln(ExtSp('Full charge life time:',nl),GetMinSec(BatteryFullLifeTime));
        end;
      end;
    end;
  writeln;
{$IFDEF Debug}
  WaitForAnyKey;
{$EndIf}

end.
