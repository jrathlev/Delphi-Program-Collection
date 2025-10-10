(* Delphi program
   Show session data for the logged-in user
   ========================================

   © Dr. J. Rathlev, D-24222 Schwentinental (pb(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - May 2018
   *)

program ShowSession;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, WinApiUtils, ExtSysUtils;

const
  sLogonType : array[TSecurityLogonType] of string = ('','',
    'Interactive', 'Network', 'Batch', 'Service', 'Proxy', 'Unlock',
    'NetworkCleartext', 'NewCredentials', 'RemoteInteractive',
    'CachedInteractive', 'CachedRemoteInteractive');

var
  sd : TSessionData;
begin
  if GetUserSessionData(sd) then with sd do begin
    writeln('Username  : ',Username);
    writeln('Domain    : ', Domain);
//    writeln('User LUID : ');
    writeln('Logon type: ',sLogonType[LogonType]);
    writeln('Logon time: ',DateTimeToStr(LogonTime));
    end
  else writeln('Error reading session data: ',SysErrorMessage(GetLastError));
{$ifdef DEBUG}
  WaitForAnyKey;
{$endif}
end.
