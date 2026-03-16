# Create New Azure AD App Registration Guide

## If you can't modify the existing app, create a new one:

### Step 1: Create New App Registration
1. Go to: https://portal.azure.com
2. Navigate to: **Azure Active Directory** → **App registrations**
3. Click **"New registration"**
4. **Name**: `SFC Dashboard Mobile App`
5. **Supported account types**: Select **"Accounts in any organizational directory (Any Azure AD directory - Multitenant)"**
6. **Redirect URI**: `msauth://com.example.sfc_dashboard`
7. Click **"Register"**

### Step 2: Get New Client ID
1. Copy the **Application (client) ID** from the overview page
2. It will look like: `12345678-1234-1234-1234-123456789012`

### Step 3: Update Flutter App
Replace the client ID in `lib/service/AuthService.dart`:

```dart
static const String _clientId = 'YOUR_NEW_CLIENT_ID_HERE';
```

### Step 4: Configure API Permissions
1. Click **"API permissions"** in the left menu
2. Click **"Add a permission"**
3. Select **"Microsoft Graph"**
4. Select **"Delegated permissions"**
5. Add these permissions:
   - `User.Read`
   - `openid`
   - `profile`
   - `email`
6. Click **"Add permissions"**
7. Click **"Grant admin consent"**

### Step 5: Test the New App
1. Update the client ID in your code
2. Run the app
3. Try logging in with your account

## Benefits of New App Registration:
- ✅ You have full control
- ✅ Configured for multi-tenant from start
- ✅ No dependency on existing app owner
- ✅ Can customize permissions as needed 