#!/usr/bin/env python3
"""Set version localizations (ja/en), keywords, URLs, and age rating.
Discovers the app by bundle id. Idempotent."""
import jwt, time, requests, os

KEY_ID = 'WDXGY9WX55'
ISSUER = '2be0734f-943a-4d61-9dc9-5d9045c46fec'
BUNDLE = 'com.tokyonasu.LazyChart'
p8 = open(os.path.expanduser('~/.appstoreconnect/private_keys/AuthKey_WDXGY9WX55.p8')).read()

DESC_EN = (
    "Make a chart in seconds. No spreadsheet, no laptop, no fuss.\n\n"
    "Lazy Chart is for people who just want a clean bar, line, or pie chart and then get on "
    "with their day. Type your numbers into a simple table, or paste a CSV, and the chart draws "
    "itself. Tap once to share it by email, message, or anywhere else.\n\n"
    "\u2022 Bar, line, and pie charts\n"
    "\u2022 Enter data in a plain table \u2014 like a tiny spreadsheet\n"
    "\u2022 Import or paste CSV\n"
    "\u2022 Multiple series, custom labels, value tags, legend, grid\n"
    "\u2022 Five color palettes\n"
    "\u2022 Export a crisp image and share it in one tap\n"
    "\u2022 Save as many charts as you like\n"
    "\u2022 Works offline. No account, no ads, no tracking\n\n"
    "One-time purchase. Open it, make the chart, send it, done."
)

DESC_JA = (
    "\u30b0\u30e9\u30d5\u3092\u6570\u79d2\u3067\u3002\u30a8\u30af\u30bb\u30eb\u3082\u30d1\u30bd\u30b3\u30f3\u3082\u3044\u308a\u307e\u305b\u3093\u3002\n\n"
    "\u30ba\u30dc\u30e9\u30b0\u30e9\u30d5\u306f\u3001\u68d2\u30b0\u30e9\u30d5\u30fb\u7dda\u30b0\u30e9\u30d5\u30fb\u5186\u30b0\u30e9\u30d5\u3092\u3068\u306b\u304b\u304f\u3055\u3063\u3068\u4f5c\u3063\u3066\u9001\u308a\u305f\u3044\u4eba\u306e\u305f\u3081\u306e\u30a2\u30d7\u30ea\u3067\u3059\u3002\u5c0f\u3055\u306a\u8868\u306b\u6570\u5b57\u3092\u5165\u308c\u308b\u304b\u3001CSV\u3092\u8cbc\u308a\u4ed8\u3051\u308b\u3060\u3051\u3002\u30b0\u30e9\u30d5\u306f\u81ea\u52d5\u3067\u63cf\u304b\u308c\u307e\u3059\u3002\u3042\u3068\u306f1\u30bf\u30c3\u30d7\u3067\u30e1\u30fc\u30eb\u3084\u30e1\u30c3\u30bb\u30fc\u30b8\u306b\u9001\u308b\u3060\u3051\u3002\n\n"
    "\u30fb\u68d2\u30b0\u30e9\u30d5\u30fb\u7dda\u30b0\u30e9\u30d5\u30fb\u5186\u30b0\u30e9\u30d5\n"
    "\u30fb\u5c0f\u3055\u306a\u8868\u306b\u76f4\u63a5\u5165\u529b\u3001\u30df\u30cb\u30b9\u30d7\u30ec\u30c3\u30c9\u30b7\u30fc\u30c8\u611f\u899a\n"
    "\u30fbCSV\u306e\u8aad\u307f\u8fbc\u307f\u30fb\u8cbc\u308a\u4ed8\u3051\n"
    "\u30fb\u8907\u6570\u7cfb\u5217\u3001\u30e9\u30d9\u30eb\u3001\u5024\u306e\u8868\u793a\u3001\u51e1\u4f8b\u3001\u30b0\u30ea\u30c3\u30c9\n"
    "\u30fb5\u3064\u306e\u30ab\u30e9\u30fc\u30d1\u30ec\u30c3\u30c8\n"
    "\u30fb\u304d\u308c\u3044\u306a\u753b\u50cf\u3092\u66f8\u304d\u51fa\u3057\u30661\u30bf\u30c3\u30d7\u3067\u5171\u6709\n"
    "\u30fb\u30b0\u30e9\u30d5\u306f\u3044\u304f\u3064\u3067\u3082\u4fdd\u5b58\n"
    "\u30fb\u30aa\u30d5\u30e9\u30a4\u30f3\u3067\u52d5\u4f5c\u3002\u30a2\u30ab\u30a6\u30f3\u30c8\u4e0d\u8981\u3001\u5e83\u544a\u306a\u3057\u3001\u8ffd\u8de1\u306a\u3057\n\n"
    "\u8cb7\u3044\u5207\u308a\u3002\u958b\u3044\u3066\u3001\u4f5c\u3063\u3066\u3001\u9001\u3063\u3066\u3001\u7d42\u308f\u308a\u3002"
)

KW_EN = "chart,graph,bar chart,pie chart,line graph,csv,spreadsheet,data,report,visualize,excel"
KW_JA = "\u30b0\u30e9\u30d5,\u8868,\u68d2\u30b0\u30e9\u30d5,\u5186\u30b0\u30e9\u30d5,\u7dda\u30b0\u30e9\u30d5,csv,\u30a8\u30af\u30bb\u30eb,\u30c7\u30fc\u30bf,\u8cc7\u6599,\u30b0\u30e9\u30d5\u4f5c\u6210,\u5171\u6709"

PROMO_EN = "Type a few numbers, get a clean chart, share it in one tap. No spreadsheet needed."
PROMO_JA = "\u6570\u5b57\u3092\u5165\u308c\u308b\u3060\u3051\u3067\u304d\u308c\u3044\u306a\u30b0\u30e9\u30d5\u30021\u30bf\u30c3\u30d7\u3067\u5171\u6709\u3002\u30a8\u30af\u30bb\u30eb\u306f\u3044\u308a\u307e\u305b\u3093\u3002"

URL = "https://snarfnet.github.io/"

LOCS = {
    'en-US': dict(description=DESC_EN, keywords=KW_EN, promotionalText=PROMO_EN,
                  marketingUrl=URL, supportUrl=URL),
    'ja': dict(description=DESC_JA, keywords=KW_JA, promotionalText=PROMO_JA,
               marketingUrl=URL, supportUrl=URL),
}


def tok():
    return jwt.encode({'iss': ISSUER, 'iat': int(time.time()), 'exp': int(time.time()) + 1200,
                       'aud': 'appstoreconnect-v1'}, p8, algorithm='ES256', headers={'kid': KEY_ID})


def api(m, p, payload=None):
    h = {'Authorization': f'Bearer {tok()}', 'Content-Type': 'application/json'}
    return requests.request(m, f'https://api.appstoreconnect.apple.com/v1{p}',
                            headers=h, **({'json': payload} if payload else {}))


APP_ID = api('GET', f'/apps?filter[bundleId]={BUNDLE}&limit=1').json()['data'][0]['id']
VERSION_ID = api('GET', f'/apps/{APP_ID}/appStoreVersions?filter[platform]=IOS&limit=1').json()['data'][0]['id']
print('app', APP_ID, 'version', VERSION_ID)

existing = {l['attributes']['locale']: l['id']
            for l in api('GET', f'/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations?limit=20').json()['data']}
print('existing locales', list(existing))

for locale, attrs in LOCS.items():
    if locale in existing:
        lid = existing[locale]
        r = api('PATCH', f'/appStoreVersionLocalizations/{lid}',
                {'data': {'type': 'appStoreVersionLocalizations', 'id': lid, 'attributes': attrs}})
    else:
        r = api('POST', '/appStoreVersionLocalizations',
                {'data': {'type': 'appStoreVersionLocalizations',
                          'attributes': {'locale': locale, **attrs},
                          'relationships': {'appStoreVersion': {'data': {'type': 'appStoreVersions', 'id': VERSION_ID}}}}})
    print(locale, r.status_code, '' if r.status_code < 300 else r.text[:300])

# Age rating: utility app -> all none/false
inf = api('GET', f'/apps/{APP_ID}/appInfos?include=ageRatingDeclaration').json()
decl_id = None
for i in inf.get('included', []):
    if i['type'] == 'ageRatingDeclarations':
        decl_id = i['id']
if decl_id:
    age_attrs = {
        'alcoholTobaccoOrDrugUseOrReferences': 'NONE',
        'contests': 'NONE',
        'gamblingSimulated': 'NONE',
        'medicalOrTreatmentInformation': 'NONE',
        'profanityOrCrudeHumor': 'NONE',
        'sexualContentGraphicAndNudity': 'NONE',
        'sexualContentOrNudity': 'NONE',
        'horrorOrFearThemes': 'NONE',
        'matureOrSuggestiveThemes': 'NONE',
        'violenceCartoonOrFantasy': 'NONE',
        'violenceRealisticProlongedGraphicOrSadistic': 'NONE',
        'violenceRealistic': 'NONE',
        'gambling': False,
        'unrestrictedWebAccess': False,
        'kidsAgeBand': None,
    }
    r = api('PATCH', f'/ageRatingDeclarations/{decl_id}',
            {'data': {'type': 'ageRatingDeclarations', 'id': decl_id, 'attributes': age_attrs}})
    print('age rating', r.status_code, '' if r.status_code < 300 else r.text[:400])
print('metadata done')
