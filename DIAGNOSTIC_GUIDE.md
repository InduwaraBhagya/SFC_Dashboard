# Diagnostic Guide: Authentication Issues

## Current Status
- ✅ Azure AD app is configured for multi-tenant
- ✅ Client ID is correct: `b0320ea2-0e34-4900-9839-8fca9beb051b`
- ❌ Authentication still failing

## 🔍 **Step-by-Step Diagnosis**

### **Step 1: Test Redirect URIs**
1. **Run the app**
2. **Click "Test Redirect URIs"** button
3. **Check console logs** for results
4. **Look for**: Which redirect URI works (if any)

### **Step 2: Check Azure AD Redirect URI Configuration**
In Azure Portal → Your App → Authentication → Platform configurations:

**Required Redirect URIs:**
```
msauth://com.example.sfc_dashboard
msauth://com.example.sfc_dashboard/redirect
```

**If these are missing:**
1. **Click "Add a platform"**
2. **Select "Mobile and desktop applications"**
3. **Add the URIs above**
4. **Click "Configure" and "Save"**

### **Step 3: Verify API Permissions**
In Azure Portal → Your App → API permissions:

**Required Permissions:**
- ✅ `User.Read` (Microsoft Graph)
- ✅ `openid` (Microsoft Graph)
- ✅ `profile` (Microsoft Graph)
- ✅ `email` (Microsoft Graph)

**To add missing permissions:**
1. **Click "Add a permission"**
2. **Select "Microsoft Graph"**
3. **Select "Delegated permissions"**
4. **Add the missing permissions**
5. **Click "Grant admin consent"**

### **Step 4: Check App Registration Details**
In Azure Portal → Your App → Overview:

**Verify these settings:**
- ✅ **Application (client) ID**: `b0320ea2-0e34-4900-9839-8fca9beb051b`
- ✅ **Directory (tenant) ID**: `5320c60a-f5d9-43ad-b69b-645375b6a694`
- ✅ **Supported account types**: Multi-tenant

### **Step 5: Test Authentication Flow**
1. **Click "Test Auth Configuration"** button
2. **Watch console logs** for detailed output
3. **Look for specific error messages**

## 🚨 **Common Issues & Solutions**

### **Issue 1: "AADSTS50011" - Redirect URI Mismatch**
**Symptoms**: Authentication fails with redirect URI error
**Solution**: Add missing redirect URIs to Azure AD app

### **Issue 2: "AADSTS70002" - Invalid Client**
**Symptoms**: Authentication fails with client credential error
**Solution**: Verify client ID matches Azure AD app

### **Issue 3: "null_intent" - Authentication Flow Issue**
**Symptoms**: App crashes or loses connection during auth
**Solution**: Check AndroidManifest.xml intent filters

### **Issue 4: "AADSTS50020" - Tenant Access**
**Symptoms**: Account access denied error
**Solution**: Already fixed with multi-tenant configuration

## 🔧 **Testing Tools Added**

### **Test Redirect URIs Button**
- Tests 4 different redirect URI configurations
- Shows which URI works (if any)
- Provides detailed console output

### **Test Auth Configuration Button**
- Validates basic authentication setup
- Checks client ID and issuer configuration
- Provides configuration status

### **Enhanced Console Logging**
- Step-by-step authentication progress
- Detailed error analysis
- Multiple authentication attempts

## 📱 **What to Do Next**

### **Immediate Actions:**
1. **Run the app**
2. **Click "Test Redirect URIs"** first
3. **Check console logs** for results
4. **Click "Test Auth Configuration"**
5. **Try "Login with Microsoft"**

### **Based on Results:**
- **If redirect URI test fails**: Add missing URIs to Azure AD
- **If auth config test fails**: Check client ID and permissions
- **If login still fails**: Check console logs for specific error

## 📋 **Checklist**

- [ ] Azure AD app is multi-tenant ✅
- [ ] Client ID matches: `b0320ea2-0e34-4900-9839-8fca9beb051b` ✅
- [ ] Redirect URIs are configured in Azure AD
- [ ] API permissions are granted
- [ ] AndroidManifest.xml has correct intent filters ✅
- [ ] Console logs show detailed debugging ✅

## 🎯 **Expected Results**

### **If Everything Works:**
- ✅ Redirect URI test finds working URI
- ✅ Auth configuration test passes
- ✅ Login succeeds and navigates to dashboard

### **If Issues Remain:**
- ❌ Redirect URI test shows all URIs failed
- ❌ Auth configuration test fails
- ❌ Login fails with specific error message

**The enhanced debugging will show exactly what's failing and provide specific solutions.** 