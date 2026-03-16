# Azure AD Setup Guide - Fix AADSTS50020 Error

## Error Explanation: AADSTS50020

The error `AADSTS50020` means:
- **User account exists in a different Azure AD tenant**
- **Your app is registered in a different tenant**
- **The user doesn't have access to your app's tenant**

## 🔧 IMMEDIATE FIX: Configure Multi-Tenant App

### Step 1: Update Azure AD App Registration

1. **Go to Azure Portal**: https://portal.azure.com
2. **Sign in** with the account that owns the app registration
3. **Navigate to**: Azure Active Directory → App registrations
4. **Find your app**: `b0320ea2-0e34-4900-9839-8fca9beb051b` (SLTFlutterApp)
5. **Click on the app name** to open it

### Step 2: Change Authentication Settings

1. **Click "Authentication"** in the left menu
2. **Scroll down to "Supported account types"**
3. **Change from**: "Accounts in this organizational directory only (Single tenant)"
4. **Change to**: "Accounts in any organizational directory (Any Azure AD directory - Multitenant)"
5. **Click "Save"**

### Step 3: Update Redirect URIs

1. **Still in Authentication page**
2. **Scroll to "Platform configurations"**
3. **Click "Add a platform"** → **"Mobile and desktop applications"**
4. **Add these redirect URIs**:
   ```
   msauth://com.example.sfc_dashboard
   msauth://com.example.sfc_dashboard/redirect
   ```
5. **Click "Configure"**
6. **Click "Save"**

### Step 4: Update App Manifest (Alternative Method)

If the above doesn't work:

1. **Click "Manifest"** in the left menu
2. **Find this line**: `"signInAudience": "AzureADMyOrg"`
3. **Change it to**: `"signInAudience": "AzureADMultipleOrgs"`
4. **Click "Save"**

## 🧪 Test the Fix

1. **Wait 5-10 minutes** for changes to propagate
2. **Try logging in** with your account: `21it0482@itum.mrt.ac.lk`
3. **Check console logs** for detailed information

## 🔍 Alternative Solutions

### Option A: Add User as Guest (If you can't modify app settings)

1. **Go to Azure Portal**: https://portal.azure.com
2. **Navigate to**: Azure Active Directory → Users
3. **Click "New guest user"**
4. **Add the user**: `21it0482@itum.mrt.ac.lk`
5. **Send invitation email**
6. **User accepts invitation**

### Option B: Use Different Account

1. **Create a new Microsoft account** in the same tenant as your app
2. **Or use an existing account** that belongs to the app's tenant

### Option C: Create New App Registration

1. **Create a new app registration** in your own tenant
2. **Update the client ID** in the code
3. **Configure it for multi-tenant**

## 🐛 Troubleshooting

### If you still get AADSTS50020:

1. **Check app registration**: Ensure multi-tenant is enabled
2. **Wait longer**: Changes can take 10-15 minutes
3. **Clear browser cache**: Log out and log back in
4. **Try different browser**: Sometimes browser cache causes issues

### If you get AADSTS50011:

1. **Check redirect URIs**: Ensure they match exactly
2. **Update AndroidManifest.xml**: Verify intent filters
3. **Test with different redirect URI**: Try the alternatives in code

## 📱 Current App Configuration

Your Flutter app is now configured to:
- ✅ **Use multi-tenant authentication** (`/common/v2.0`)
- ✅ **Fall back to specific tenant** if needed
- ✅ **Provide clear error messages**
- ✅ **Handle multiple redirect URIs**

## 🚀 Next Steps

1. **Follow Step 1-4 above** to update Azure AD
2. **Wait 10 minutes** for changes to take effect
3. **Test the authentication** again
4. **Check console logs** for debugging info

## 📞 Need Help?

If you can't access the Azure Portal or modify the app registration:
1. **Contact the app owner** (whoever created the app registration)
2. **Ask them to follow the steps above**
3. **Or provide them with this guide**

## 🔗 Useful Links

- **Azure Portal**: https://portal.azure.com
- **Microsoft Documentation**: https://docs.microsoft.com/en-us/azure/active-directory/
- **Azure AD App Registration**: https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade 