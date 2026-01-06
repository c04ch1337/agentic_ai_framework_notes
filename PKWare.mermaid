graph LR
    %% --- CLOUD LAYER ---
    subgraph Cloud["Cloud – Azure Tenant"]
        AAD[Azure Entra ID<br/>(Tenant)]
        EA[Enterprise App<br/>(PKWARE / Smartcrypt)]
    end

    %% --- DATACENTER / SERVER LAYER ---
    subgraph DC["On-Prem / VM – PKWARE Core"]
        AdminConsole[PKWARE Admin Console<br/>& Windows Service]
        Policies[Auth Policies<br/>& Encryption Policies]
        FileStore[File Shares / Repos<br/>(Encrypted Data)]
    end

    %% --- ENDPOINTS ---
    subgraph Endpoints["Endpoints – Users & Servers"]
        WinA[PKWARE Agent<br/>Windows]
        MacA[PKWARE Agent<br/>macOS]
        LinA[PKWARE Agent<br/>Linux]
    end

    %% --- PEOPLE / ADMINS ---
    SecurityAdmin[Security Admin<br/>(You / Infosec)]
    TenantAdmin[Brooke / Travis<br/>(Azure Tenant Admin)]

    %% FLOWS: ADMIN SSO
    SecurityAdmin -->|Browser SSO| AdminConsole
    AdminConsole -->|Redirect / SAML-OIDC| AAD
    AAD -->|Issues Token for<br/>PKWARE Enterprise App| AdminConsole
    AdminConsole --> Policies
    Policies --> AdminConsole

    %% FLOWS: AZURE APP CONSENT
    EA -->|Consent Required| TenantAdmin
    TenantAdmin -->|Grant Access<br/>(Tenant-wide or Group)| EA
    EA --> AAD

    %% FLOWS: AGENT ENROLLMENT & POLICY
    WinA -->|Enroll / Check-in| AdminConsole
    MacA -->|Enroll / Check-in| AdminConsole
    LinA -->|Enroll / Check-in| AdminConsole

    AdminConsole -->|Distribute Auth Policies<br/>+ Encryption Rules| WinA
    AdminConsole -->|Distribute Auth Policies<br/>+ Encryption Rules| MacA
    AdminConsole -->|Distribute Auth Policies<br/>+ Encryption Rules| LinA

    %% FLOWS: DATA PROTECTION
    WinA -->|Encrypt / Decrypt<br/>based on policy| FileStore
    MacA -->|Encrypt / Decrypt<br/>based on policy| FileStore
    LinA -->|Encrypt / Decrypt<br/>based on policy| FileStore

    %% AUTH POLICIES CONCEPT
    Policies -->|Define which<br/>Identity the Agent uses| WinA
    Policies -->|User, Device, or Service Identity| MacA
    Policies --> LinA
