# Authentication Troubleshooting Guide

## Current Issue: AADSTS50020 - Tenant Access Problem

### 🔍 **Problem Analysis**
- **Error**: `AADSTS50020: User account does not exist in tenant`
- **Root Cause**: Your account belongs to a different Azure AD tenant than the app
- **Status**: Authentication activity starts but fails during the process

### 🚀 **Immediate Solutions**

#### **Solution 1: Update Azure AD App (Recommended)**
1. **Access Azure Portal**: https://portal.azure.com
2. **Navigate**: Azure Active Directory → App registrations
3. **Find App**: `b0320ea2-0e34-4900-9839-8fca9beb051b`
4. **Click "Authentication"**
5. **Change "Supported account types"** to:
   - **"Accounts in any organizational directory (Any Azure AD directory - Multitenant)"**
6. **Add Redirect URIs**:
   ```
   msauth://com.example.sfc_dashboard
   msauth://com.example.sfc_dashboard/redirect
   ```
7. **Save changes**

#### **Solution 2: Create New App Registration**
If you can't modify the existing app:
1. **Create new app** in your own tenant
2. **Follow**: `CREATE_NEW_APP_GUIDE.md`
3. **Update client ID** in the code

#### **Solution 3: Add User as Guest**
1. **Go to**: Azure Portal → Azure Active Directory → Users
2. **Click**: "New guest user"
3. **Add**: `21it0482@itum.mrt.ac.lk`
4. **Send invitation**

### 🧪 **Testing Steps**

#### **Step 1: Test Configuration**
1. **Run the app**
2. **Click "Test Auth Configuration"** button
3. **Check console logs** for detailed output
4. **Look for**: Configuration validation results

#### **Step 2: Test Authentication**
1. **Click "Login with Microsoft"**
2. **Watch console logs** for detailed debugging
3. **Look for**: Step-by-step authentication progress
4. **Check for**: Specific error messages

#### **Step 3: Check Error Types**
The app now provides detailed error analysis:
- **AADSTS50020**: Tenant access issue
- **AADSTS50011**: Redirect URI mismatch
- **AADSTS70002**: Invalid client credentials
- **null_intent**: Authentication flow issue

### 🔧 **Debugging Information**

#### **Console Logs to Look For**
```
=== STARTING MICROSOFT AUTHENTICATION ===
=== ATTEMPT 1: Common endpoint (multi-tenant) ===
=== ATTEMPT 1: FAILED ===
Error details: [specific error]
=== ERROR ANALYSIS ===
TENANT ACCESS ISSUE: Your account does not have access
```

#### **What Each Log Means**
- **"Authorization request created successfully"**: Basic config is working
- **"Starting authorizeAndExchangeCode"**: Authentication flow starting
- **"SUCCESS"**: Authentication completed
- **"FAILED"**: Authentication failed with specific error

### 📱 **App Features Added**

#### **Enhanced Debugging**
- ✅ **Detailed console logs** for each step
- ✅ **Error type analysis** with specific solutions
- ✅ **Configuration testing** button
- ✅ **Multiple authentication attempts** with different settings

#### **Error Handling**
- ✅ **Specific error messages** for different scenarios
- ✅ **Step-by-step debugging** information
- ✅ **Fallback authentication** methods
- ✅ **Clear user feedback** with SnackBar messages

### 🚨 **Common Issues & Solutions**

#### **Issue 1: "Lost connection to device"**
**Cause**: Authentication activity crashes
**Solution**: Check AndroidManifest.xml intent filters

#### **Issue 2: "AADSTS50020" persists**
**Cause**: Azure AD app still single-tenant
**Solution**: Update app registration to multi-tenant

#### **Issue 3: "null_intent" error**
**Cause**: Intent filter configuration issue
**Solution**: Verify AndroidManifest.xml redirect URI

#### **Issue 4: "AADSTS50011"**
**Cause**: Redirect URI not configured in Azure AD
**Solution**: Add redirect URIs to app registration

### 📞 **Next Steps**

1. **Try the "Test Auth Configuration" button** first
2. **Check console logs** for detailed debugging
3. **Follow the specific error message** guidance
4. **Update Azure AD app** if needed
5. **Test authentication** again

### 🔗 **Useful Files**
- `AZURE_AD_SETUP_GUIDE.md`: Complete Azure AD setup
- `CREATE_NEW_APP_GUIDE.md`: Create new app registration
- `TROUBLESHOOTING_GUIDE.md`: This file

### 📋 **Checklist**
- [ ] Azure AD app is multi-tenant
- [ ] Redirect URIs are configured
- [ ] Client ID is correct
- [ ] AndroidManifest.xml has intent filters
- [ ] Console logs show detailed debugging
- [ ] Error messages are specific and helpful 