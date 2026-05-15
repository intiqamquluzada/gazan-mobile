# Qazan

> Sadiqlik və müştəri izləmə platforması — kafelər, restoranlar, gözəllik salonları, avtoyumalar üçün.

Qazan iki rolu bir tətbiqdə birləşdirir:

- **Müştəri** — yaxınlıqdakı obyektləri kəşf edir, sadiqlik kartlarını topla­yır, ödəyəndə QR-ini göstərir, mükafatlarını görür.
- **Biznes** — sadiqlik proqramlarını yaradır, müştərinin QR-ini skan edir, möhür əlavə edir, müştəriləri izləyir.

İndilik backend yoxdur — bütün məlumat in-memory **mock repository**-lər­dən gəlir. Real API qoşulanda yalnız `data/` qatında dəyişiklik edilir, qalan kod toxunulmadan qalır.

---

## İlk dəfə qaçırmaq

```bash
# Asılılıqları yüklə
flutter pub get

# Platform qovluqlarını yarat (yalnız ilk dəfə)
flutter create . --platforms=android,ios

# İşə sal
flutter run
```

> Layihə `flutter: >=3.27.0` tələb edir (yeni `withValues` və `CardThemeData` API-ları üçün).

---

## Arxitektura

Hər bir feature öz `domain / data / application / presentation` qatlarına bölünür — Clean Architecture-in yüngül variantı. Riverpod state management üçün, go_router naviqasiya üçün istifadə olunur.

```
lib/
├── main.dart                       # WidgetsBinding + ProviderScope + intl init
├── app.dart                        # MaterialApp.router + temalar
├── routing/
│   └── app_router.dart             # Bütün marşrutlar, redirect məntiqi
│
├── core/                           # Feature-lərə bağlı olmayan ümumi kod
│   ├── theme/                      # Rənglər, tipoqrafiya, spacing, ThemeData
│   ├── constants/                  # Mətnlər (sonra .arb-ə köçürmək asan)
│   ├── utils/                      # Extension-lar, format helper-lər
│   └── widgets/                    # PrimaryButton, AppTextField, EmptyState, ...
│
└── features/
    ├── auth/                       # Splash, onboarding, role picker, login, register
    │   ├── domain/                 # AppUser, UserRole
    │   ├── application/            # AuthController + Riverpod provider-lər
    │   └── presentation/
    │
    ├── companies/                  # Discover feed + obyektin detal səhifəsi
    │   ├── domain/                 # Company, BusinessCategory
    │   ├── data/                   # CompaniesRepository (mock)
    │   ├── application/            # Provider-lər: featured, filtered list
    │   └── presentation/
    │       ├── widgets/            # CompanyCard, CategoryChips
    │       ├── discover_screen.dart
    │       └── company_detail_screen.dart
    │
    ├── loyalty/                    # Sadiqlik məntiqi (kart, möhür, mükafat)
    │   ├── domain/                 # LoyaltyProgram, LoyaltyCard, LoyaltyEvent
    │   ├── data/                   # LoyaltyRepository (mock)
    │   ├── application/            # myCardsProvider, LoyaltyActions
    │   └── presentation/
    │       ├── widgets/            # LoyaltyCardWidget, StampGrid
    │       └── my_cards_screen.dart
    │
    ├── qr/                         # Müştəri tərəf: QR göstər, biznes tərəf: skan
    │   └── presentation/
    │       ├── qr_display_screen.dart   # qr_flutter
    │       └── qr_scanner_screen.dart   # mobile_scanner + custom overlay
    │
    ├── profile/                    # Müştərinin profili, statistika, çıxış
    │   └── presentation/
    │
    ├── business/                   # Biznes tərəf — dashboard, müştərilər, proqramlar
    │   ├── domain/
    │   ├── data/
    │   ├── application/
    │   └── presentation/
    │
    └── home/
        └── presentation/
            ├── customer_shell.dart   # Bottom nav (Müştəri tərəf)
            └── business_shell.dart   # Bottom nav (Biznes tərəf)
```

### Marşrutlar

| Yol                  | Rol      | Səhifə                            |
| -------------------- | -------- | --------------------------------- |
| `/splash`            | —        | İlk açılış                         |
| `/onboarding`        | —        | 3 slaydlıq onboarding              |
| `/role`              | —        | Müştəri / Biznes seçimi            |
| `/login?role=...`    | —        | Daxil olma                         |
| `/register?role=...` | —        | Qeydiyyat                          |
| `/home`              | Müştəri  | Discover (axtarış, kategoriyalar)  |
| `/cards`             | Müştəri  | Sadiqlik kartlarım                 |
| `/qr`                | Müştəri  | QR-imi göstər                      |
| `/profile`           | Müştəri  | Profil                             |
| `/companies/:id`     | İkisi də | Biznesin detalı + proqramlar       |
| `/business`          | Biznes   | Dashboard (statistika)             |
| `/business/scan`     | Biznes   | QR skaner                          |
| `/business/customers`| Biznes   | Müştərilərin siyahısı              |
| `/business/programs` | Biznes   | Sadiqlik proqramlarını idarə et    |

---

## Backend qoşulanda nə dəyişir?

Bütün UI və state management hazırdır. Real API qoşulanda yalnız bir neçə fayla toxunulmalıdır:

1. `lib/features/*/data/*_repository.dart` — `MockXxxRepository` sinfini HTTP/Firestore variantı ilə əvəz et. Interface-lər (`CompaniesRepository`, `LoyaltyRepository`, `BusinessRepository`) toxunulmadan qalır.
2. `lib/features/auth/application/auth_controller.dart` — `signIn`, `signUp` metodlarını real auth servisi ilə əvəz et.
3. `lib/features/*/application/*_providers.dart` — repository provider-lərinin `Provider` body-sini real implementasiyaya yönləndir (məsələn DI vasitəsi ilə).

Geri qalan UI, ekran, state, naviqasiya kodu dəyişməz qalır.

---

## Demo məlumat

Mock repository-lər real istifadə üçün hazır səhnə qurur:

- 8 obyekt: The Bagel Bar, Coffee Moose, Saray Burger, Glow Studio, Aqua Wash, Fit Lab, Sweet House, Barber House.
- 9 sadiqlik proqramı: hər biri 4-10 möhür arasında.
- Demo müştərinin 4 aktiv kartı var (biri artıq mükafatlı).
- Biznes profilində 5 müştəri və real görünüşlü statistika.

Login zamanı istənilən e-poçt/şifrə qəbul olunur — `role=customer` üçün “demo-user”, `role=business` üçün “demo-business” seansı qurulur.

---

## Sonrakı addımlar

- `flutter_secure_storage` ilə token qoruması
- Real auth (SSO/OAuth)
- HTTP client (Dio) + JSON serializasiya (json_serializable və ya freezed)
- Push bildirişlər (məs: “mükafatın hazırdır” siqnalı)
- Lokalizasiya (.arb fayllarına köçürmə — strings artıq mərkəzləşdirilib)
- Şəkil yükləmə (logo, kapak)
- Ödəniş inteqrasiyası (loyalty + check-out birləşdirmək üçün)
