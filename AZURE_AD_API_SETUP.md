# Azure AD API Authentication Setup Guide

This guide explains how to set up Azure AD authentication for your APIs in the mobile app.

## Overview

Your mobile app now uses Azure AD authentication to:
1. **Authenticate users** with Microsoft accounts
2. **Get access tokens** for API calls
3. **Securely store tokens** using `flutter_secure_storage`
4. **Make authenticated API requests** to your backend

## Current Setup

### 1. Authentication Flow
```
User Login → Microsoft Azure AD → Get Access Token → Store Token → Use for API Calls
```

### 2. Token Storage
- **Access Token**: Stored securely using `flutter_secure_storage`
- **User Info**: Stored as JSON in secure storage
- **Refresh Token**: Stored for token renewal (if available)

### 3. API Authentication
All API calls now include the Azure AD access token in the Authorization header:
```
Authorization: Bearer <access_token>
```

## Backend API Requirements

Your backend APIs must be configured to:

### 1. Validate Azure AD Tokens
```csharp
// Example C# code for validating tokens
[Authorize]
[ApiController]
public class WorkGroupController : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> Get()
    {
        // Token is automatically validated by Azure AD middleware
        var user = User.Identity.Name;
        // Your API logic here
    }
}
```

### 2. Configure Azure AD Authentication
In your `appsettings.json`:
```json
{
  "AzureAd": {
    "Instance": "https://login.microsoftonline.com/",
    "Domain": "your-domain.com",
    "TenantId": "your-tenant-id",
    "ClientId": "your-api-client-id",
    "Audience": "api://your-api-client-id"
  }
}
```

### 3. Add Authentication Middleware
In `Startup.cs`:
```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddMicrosoftIdentityWebApi(Configuration.GetSection("AzureAd"));
}
```

## Mobile App Configuration

### 1. API Service (`lib/service/ApiService.dart`)
- Automatically includes access token in all requests
- Handles 401 errors (token expired)
- Clears stored tokens on authentication failure

### 2. Auth Service (`lib/service/AuthService.dart`)
- Handles Microsoft login
- Stores tokens securely
- Provides session management

### 3. Session Management
- `AuthWrapper` in `main.dart` checks login status
- Automatically navigates to dashboard if logged in
- Handles logout and token cleanup

## API Endpoints

Your backend should have these endpoints protected with Azure AD:

```
GET  /WorkGroup           - Get work groups
GET  /PERecord           - Get PE records  
GET  /RegularRecord      - Get regular records
GET  /UrgentRecord       - Get urgent records
GET  /HoldRecord         - Get hold records
GET  /OLAViolationRecord - Get OLA violation records
GET  /Permission         - Get permissions
GET  /PETask            - Get PE tasks
GET  /PETaskList        - Get PE task lists
GET  /health            - Health check endpoint
```

## Testing the Setup

### 1. Test Authentication
```bash
# Run the app
flutter run

# Login with Microsoft account
# Check if tokens are stored
# Verify API calls work
```

### 2. Test API Connectivity
The app will automatically test API connectivity and show errors if:
- Network is unavailable
- API server is down
- Authentication fails
- Token is expired

### 3. Debug API Issues
Check the console logs for:
- `API request error: ...`
- `Error fetching work groups: ...`
- `Authentication failed. Please login again.`

## Troubleshooting

### Common Issues

1. **401 Unauthorized**
   - Token expired or invalid
   - Backend not configured for Azure AD
   - Wrong audience/tenant configuration

2. **Network Errors**
   - API server not running
   - Wrong API URL
   - Network connectivity issues

3. **Authentication Errors**
   - Azure AD app not configured correctly
   - Missing redirect URIs
   - Wrong client ID

### Debug Steps

1. **Check Token Storage**
   ```dart
   final token = await AuthService().getAccessToken();
   print('Token: $token');
   ```

2. **Test API Manually**
   ```bash
   curl -H "Authorization: Bearer YOUR_TOKEN" \
        https://your-api-url/WorkGroup
   ```

3. **Check Backend Logs**
   - Look for authentication middleware errors
   - Verify token validation
   - Check CORS configuration

## Security Best Practices

1. **Token Storage**
   - Tokens stored in `flutter_secure_storage`
   - Automatically cleared on logout
   - No tokens in app logs

2. **API Security**
   - All endpoints require authentication
   - Tokens validated on every request
   - Proper error handling for auth failures

3. **Network Security**
   - HTTPS required for all API calls
   - Certificate pinning recommended
   - No sensitive data in logs

## Next Steps

1. **Configure your backend** with Azure AD authentication
2. **Update API URLs** in `ApiService.dart` to point to your server
3. **Test the full flow** from login to API calls
4. **Add error handling** for network issues
5. **Implement token refresh** if needed

## Support

If you encounter issues:
1. Check the console logs for error messages
2. Verify Azure AD app configuration
3. Test API endpoints manually
4. Check network connectivity
5. Review backend authentication setup 