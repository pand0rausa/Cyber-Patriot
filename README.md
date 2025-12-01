To import the basic security settings into a Windows system (local policy) or domain GPO, use Microsoft's LGPO.exe tool from the Security Compliance Toolkit. Download it from the official Microsoft site (search for "Microsoft Security Compliance Toolkit").
Save the following content as BasicSecurity.inf (a security template file). Then, run as Administrator:

LGPO.exe /s C:\Path\To\BasicSecurity.inf
This applies account policies, audits, user rights, and key security options. 
For domain GPOs, import the inf via Security Configuration and Analysis snap-in or secedit.exe (e.g., secedit /configure /db temp.sdb /cfg BasicSecurity.inf /areas SECURITYPOLICY).


To run the PowerShell script (Windows security audit):

Save the script as a .ps1 file (e.g., BasicSecurity.ps1).
Open an elevated PowerShell prompt (Run as Administrator—critical for accessing user/group details, otherwise it may fail with access denied flaws).
If execution policy restricts it, temporarily set it: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass.
Run: .\BasicSecurity.ps1 (from the script's directory) or powershell.exe -File C:\Path\To\BasicSecurity.ps1.


To run the Bash script (Linux security audit):

Save the script as a .sh file (e.g., BasicSecurity.sh).
Make it executable: chmod +x BasicSecurity.sh.
Run as root (for /etc/shadow access—use sudo to avoid privilege escalation risks): sudo ./BasicSecurity.sh or sudo bash BasicSecurity.sh.

Security note: Non-root runs miss password flaws; check for sudoers misconfigs that could allow unauthorized elevation.
