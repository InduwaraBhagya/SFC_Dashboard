# Quick Fix: Create New Azure AD App Registration

## If you can't modify the existing app, create a new one:

### Step 1: Create New App Registration
1. **Go to**: https://portal.azure.com
2. **Sign in** with your Microsoft account
3. **Navigate to**: Azure Active Directory → App registrations
4. **Click**: "New registration"
5. **Fill in**:
   - **Name**: `SFC Dashboard Mobile App`
   - **Supported account types**: **"Accounts in any organizational directory (Any Azure AD directory - Multitenant)"**
   - **Redirect URI**: `msauth://com.example.sfc_dashboard`
6. **Click**: "Register"

### Step 2: Get New Client ID
1. **Copy the Application (client) ID** from the overview page
2. **It will look like**: `12345678-1234-1234-1234-123456789012`

### Step 3: Update Flutter App
Replace the client ID in `lib/service/AuthService.dart`:

```dart
static const String _clientId = 'YOUR_NEW_CLIENT_ID_HERE';
```

### Step 4: Configure API Permissions
1. **Click**: "API permissions" in the left menu
2. **Click**: "Add a permission"
3. **Select**: "Microsoft Graph"
4. **Select**: "Delegated permissions"
5. **Add these permissions**:
   - `User.Read`
   - `openid`
   - `profile`
   - `email`
6. **Click**: "Add permissions"
7. **Click**: "Grant admin consent"

### Step 5: Test the New App
1. **Update the client ID** in your code
2. **Run the app**
3. **Try logging in** with your account

## Benefits of New App Registration:
- ✅ **You have full control**
- ✅ **Configured for multi-tenant from start**
- ✅ **No dependency on existing app owner**
- ✅ **Can customize permissions as needed**

## Time Required: 10-15 minutes 

---

## **What Causes This?**

1. **You pressed the back button** or closed the browser before logging in.
2. **The browser auto-closes** if the Microsoft login page cannot load (e.g., due to network issues, wrong URL, or Microsoft blocking the request).
3. **A popup blocker or browser setting** prevented the login page from opening.
4. **The Microsoft login page is not reachable** (network/firewall issue).

---

## **What To Do Next**

### 1. **Try Again and Wait**
- Tap "Login with Microsoft" and **wait for the Microsoft login page to fully load**.
- **Do not press back or close the browser** until you complete the login.

### 2. **Check Your Network**
- Make sure your device is connected to the internet.
- Try switching between WiFi and mobile data.

### 3. **Check the Microsoft Login Page**
- If the login page does not load, there may be a typo in the URL or a network issue.
- If you see a Microsoft login form, enter your credentials and complete the login.

### 4. **Try a Different Browser**
- If you have multiple browsers installed, set a different one as the default and try again.

### 5. **Check for Microsoft Account Restrictions**
- If your Microsoft account is blocked or has 2FA/policy restrictions, the login may fail.

---

## **If You Still Get the Error**

- **Paste the full URL** that opens in the browser (not a screenshot).
- **Describe exactly what you see**: Does the Microsoft login page appear? Does it close immediately? Do you see any error message before it closes?

---

## **Summary Table**

| Error Message         | What It Means                        | What To Do                        |
|----------------------|--------------------------------------|-----------------------------------|
| PlatformException(CANCELED, User canceled login, ...) | User closed/canceled login, or browser closed | Try again, wait for login page, check network |

---

## **If You Want to Handle This in the UI**

You can show a message to the user if they cancel the login:
```dart
catch (e) {
  if (e is PlatformException && e.code == 'CANCELED') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login canceled. Please try again.')),
    );
  } else {
    // handle other errors
  }
}
```

---

**This is not a configuration error. It means the login was canceled by the user or browser. Try again, wait for the login page, and complete the login. If the login page never appears, paste the full URL and describe what you see.** 