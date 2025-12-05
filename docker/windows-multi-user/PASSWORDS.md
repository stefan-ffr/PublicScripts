# Default Passwords

**⚠️ SECURITY WARNING: Change all passwords immediately after first login!**

This file documents the default passwords configured in `unattend.xml` for the automated Windows installation.

## Default Account Credentials

| Account       | Username      | Password    | Access Level  |
|---------------|---------------|-------------|---------------|
| Administrator | Administrator | Admin@123   | Administrator |
| User 1        | user1         | User1@123   | Administrator |
| User 2        | user2         | User2@123   | Administrator |
| User 3        | user3         | User3@123   | Administrator |

## Important Security Notes

1. **These are DEFAULT passwords** - they are the same on all containers using this configuration
2. **Change passwords immediately** after first login
3. All user accounts have **Administrator privileges**
4. Passwords are set to **never expire** for convenience (can be changed)

## How to Change Passwords

### Method 1: Via RDP Session

1. Connect via RDP to the Windows container
2. Press `Ctrl + Alt + End` (or `Ctrl + Alt + Del` if local)
3. Select "Change a password"
4. Enter current password and new password

### Method 2: Command Line

Open Command Prompt as Administrator:

```cmd
REM Change password for a specific user
net user username new-password

REM Examples:
net user user1 MyNewSecurePassword123!
net user Administrator MyAdminPassword456!
```

### Method 3: PowerShell

```powershell
# Change password for a user
$NewPassword = ConvertTo-SecureString "MyNewPassword123!" -AsPlainText -Force
Set-LocalUser -Name "user1" -Password $NewPassword

# Change password for Administrator
$AdminPassword = ConvertTo-SecureString "MyAdminPassword456!" -AsPlainText -Force
Set-LocalUser -Name "Administrator" -Password $AdminPassword
```

### Method 4: Computer Management (GUI)

1. Press `Win + R`
2. Type `lusrmgr.msc` and press Enter
3. Click on "Users"
4. Right-click on a user
5. Select "Set Password"
6. Enter new password

## Password Policy Settings

The automated installation configures:

- **Password Never Expires**: Enabled (for all users)
- **User Must Change Password at Next Login**: Disabled
- **User Cannot Change Password**: Disabled
- **Password Complexity Requirements**: Windows defaults apply

### To Enforce Password Changes

If you want to require users to change passwords on first login:

```cmd
net user user1 /logonpasswordchg:yes
net user user2 /logonpasswordchg:yes
net user user3 /logonpasswordchg:yes
```

## Customizing Default Passwords

To change the default passwords in `unattend.xml`:

1. Choose your passwords
2. Encode them in Base64
3. Update the `<Value>` fields in `unattend.xml`

### Encoding Passwords to Base64

**PowerShell:**
```powershell
$password = "YourNewPassword123!"
$bytes = [System.Text.Encoding]::Unicode.GetBytes($password + "Password")
$base64 = [Convert]::ToBase64String($bytes)
Write-Host $base64
```

**Online Tool:**
- Use: https://www.base64encode.org/
- Encoding: UTF-16LE (Unicode)
- Add "Password" suffix to your password before encoding

### Update unattend.xml

Find and replace the Base64 values:

```xml
<!-- Administrator Password -->
<AdministratorPassword>
    <Value>QWRtaW5AMTIz</Value>  <!-- Change this -->
    <PlainText>false</PlainText>
</AdministratorPassword>

<!-- User Passwords -->
<LocalAccount wcm:action="add">
    <Password>
        <Value>VXNlcjFAMTIz</Value>  <!-- Change this -->
        <PlainText>false</PlainText>
    </Password>
    ...
</LocalAccount>
```

## Password Storage Best Practices

1. **Never commit real passwords to Git** - This file documents defaults only
2. **Use a password manager** (Bitwarden is pre-installed)
3. **Use unique passwords** for each account
4. **Use strong passwords**:
   - Minimum 12 characters
   - Mix of uppercase, lowercase, numbers, symbols
5. **Document changed passwords securely** in a password manager

## Default Password Hashes (for reference)

Current Base64 encoded passwords in unattend.xml:

- `QWRtaW5AMTIz` = Admin@123Password
- `VXNlcjFAMTIz` = User1@123Password
- `VXNlcjJAMTIz` = User2@123Password
- `VXNlcjNAMTIz` = User3@123Password

Note: Windows adds "Password" suffix internally when using Base64 encoding with `PlainText=false`.

## Access After Password Change

If you forget a password and need to reset:

1. **Stop the container**: `./manage.sh stop user1`
2. **Access via web interface** while booting
3. **Use password reset tools** (offline NT password reset)
4. **Or recreate the container** (loses all data)

## Multi-User Considerations

Since Windows 11 Pro only allows **one RDP session at a time**:

- Users will log in **sequentially**, not simultaneously
- When a new user logs in, the previous user is logged out
- Save work before another user connects
- Consider using different containers for different users if simultaneous access is needed

---

**Remember: Security is only as strong as your weakest password. Change these defaults immediately!**
