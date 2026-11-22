# Apple Developer Support — TestFlight problemi

Göndərmək üçün: https://developer.apple.com/contact → **TestFlight** → mövzu
"Beta App Review submission fails" (və ya "Other"). Aşağıdakı mətni olduğu
kimi yapışdır.

---

**Subject:** TestFlight: Beta App Review submission returns 422 and internal tester invitations are never delivered

Hello,

We cannot get our app into anyone's hands through TestFlight, neither internal nor external testers.

**App:** Qazan: Sadakat ve Ödüller
**Apple ID:** 6834782185
**Bundle ID:** az.qazan.app
**Build:** 1.0.0 (2), uploaded 22 November 2026, status "Ready to Submit"

**Problem 1 — external testing (Beta App Review) fails with 422**
When we add build 1.0.0 (2) to our external group "Qazan testers" and press
"Submit for Review", App Store Connect shows "There was an error processing
your request. Please try again later." The underlying request
`POST /iris/v1/betaAppReviewSubmissions` returns HTTP 422 with
`ENTITY_UNPROCESSABLE — Please try again later.` We have retried many times
over several hours with the same result.

Everything we know to be required is complete: Test Information (beta app
description, feedback email, privacy policy URL, contact details, review
notes), primary category, content rights, the age rating questionnaire (4+),
export compliance (`ITSAppUsesNonExemptEncryption = NO` in Info.plist), and an
active Free Apps Agreement. Our role is Admin / Account Holder.

**Problem 2 — internal tester invitations never arrive**
Our internal tester intigamguluzada@icloud.com (an Admin on the team) is in
the internal group "Qazan testers" with status "Invited". We have used
"Reinvite", and removed and re-added the tester, several times. No TestFlight
invitation email ever arrives at that address. iCloud Mail is enabled on the
device, and the build is available to the group.

Could you please tell us what is blocking the Beta App Review submission, and
why internal TestFlight invitations are not being delivered?

Thank you.
