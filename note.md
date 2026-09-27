# Cohort Retention Analysis — Olist Brazilian E-Commerce

**Dataset:** [Olist Brazilian E-Commerce (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
**İstifadə olunan fayllar:** `olist_orders_dataset.csv`, `olist_customers_dataset.csv`, `olist_order_items_dataset.csv`

## Metodologiya

CSV faylları SQLite bazasına (`olist.db`) yükləndi, bütün analiz `queries.sql`-dəki sorğularla aparıldı. Notebook sorğuları həmin fayldan oxuyub işlədir.

- **Yalnız çatdırılmış sifarişlər** götürüldü (`order_status = 'delivered'`), yəni 96,478 sifariş. Ləğv olunmuş və ya çatmamış sifariş real alış sayılmır.
- **Kohort:** müştərinin ilk çatdırılmış sifarişinin ayı. Window function ilə tapıldı: `MIN() OVER (PARTITION BY customer_unique_id)`. Nəticədə 93,358 müştəri, 23 kohort alındı.
- **period_number:** sifarişin kohortdan neçə ay sonra verildiyi. `(il fərqi × 12) + ay fərqi` düsturu ilə hesablandı. Günləri 30-a bölmək ayların uzunluğu fərqli olduğu üçün səhv nəticə verə bilərdi.
- **Retention faizi:** hər periodda aktiv olan fərqli müştərilər / kohortun period 0 ölçüsü × 100. Müştərilər `COUNT(DISTINCT ...)` ilə sayıldı, çünki eyni ayda iki sifariş verən adam iki dəfə sayılmamalıdır.
- **Hələ baş verməmiş aylar:** data 2018-08-də bitir. Məsələn, 2018-05 kohortu üçün p4 və sonrası datada yoxdur. Bu xanalar 0% kimi yox, boş (NULL) saxlanıldı, çünki "heç kim qayıtmayıb" ilə "hələ bilmirik" eyni şey deyil. Ortalamalara da qatılmadı.
- **2016 kohortları ortalamadan və reytinqdən çıxarıldı.** Səbəbi: 2016-09 və 2016-12-də cəmi 1 müştəri var, 2016-11-də isə ümumiyyətlə sifariş yoxdur. Bu səbəbdən 2016-10 kohortunun p1 = 0% göstəricisi müştəri davranışını yox, datadakı boşluğu əks etdirir. Matrisdə və heatmap-də isə 2016 kohortları tamlıq üçün göstərilib.


## customer_id tələsi

Bu datasetdə `customer_id` hər **sifariş** üçün yeni yaradılır, real insanı isə `customer_unique_id` göstərir. Bunu rəqəmlər təsdiqləyir: `customers` cədvəlində 99,441 sətir və 99,441 fərqli `customer_id` var, real insan isə 96,096-dır.

Əgər analiz `customer_id` ilə aparılsaydı, eyni adamın ikinci sifarişi "yeni müştəri" kimi görünərdi. Heç kim geri qayıtmış sayılmazdı və retention əyrisi period 1-dən etibarən düz 0% olardı. Ona görə bütün hesablamalar `customer_unique_id` ilə aparılıb.

## Business Insights 

**1. Period 0 → Period 1 düşüşü çox kəskindir.** Orta retention 100%-dən **0.48%**-ə düşür. Yəni hər 1000 yeni müştəridən cəmi 4–5 nəfər növbəti ay yenidən alış edir. Müştərilərin 99.5%-dən çoxu birinci alışdan sonra geri qayıtmır.

**2. Düşüşdən sonra əyri demək olar ki, düz qalır.** p2-dən p12-yə qədər retention əsasən 0.2–0.3% arasında dəyişir, ikinci ildə isə təxminən 0.15%-ə enir. Sabit qalan sadiq müştəri qrupu yoxdur: müştəri ya dərhal gedir, ya da çox nadir hallarda təsadüfən qayıdır. Əyrinin son hissəsindəki qalxıb-enmələrə (məsələn, p17 = 0.24%, p18 = 0%) etibar etmək olmaz, çünki p15-dən sonra ortalama cəmi 1–5 kohortdan hesablanır (`n_cohorts` sütunu).

**3. Şirkət müştəri cəlb etməyi bacarır, saxlamağı yox.** Aylıq yeni müştəri sayı 2017-01-dən (717) 2017-11-ə (7,060) qədər təxminən 10 dəfə artıb, 2018-də isə 6–7 min ətrafında sabitləşib. Bu müddətdə heç bir kohortun ay-1 retention-u 1%-i keçməyib. Bütün çatdırılmış sifarişlərin cəmi 1,899-u (~2%) müştərinin ilk ayından sonra verilib.

**4. Gəlir də demək olar ki, tamamilə ilk alışdan gəlir.** Məsələn, 2018-07 kohortu ilk ayında 847,945 R$, bir ay sonra isə cəmi 3,703 R$ gəlir gətirib, yəni ilk ay gəlirinin ~0.44%-i. Böyümə tam olaraq yeni müştəri axınından asılıdır.

## Ən yaxşı və ən pis kohort

Ay-1 retention üzrə (2017+ kohortları arasında):
- **Ən yaxşı: 2017-10**, 4,328 müştəridən 31-i qayıdıb, yəni **0.72%**.
- **Ən pis: 2017-02**, 1,628 müştəridən 3-ü qayıdıb, yəni **0.18%**.

**Hipotez:** 2017-10 kohortunun "1 ay sonrası" noyabr 2017-dir, yəni Black Friday. Kampaniya köhnə müştəriləri geri gətirə bilərdi. 2017-02-nin ay-1-i isə mart ayına düşür, orada belə kampaniya yoxdur.

**Data ilə yoxlama:** retention matrisində noyabr 2017-yə düşən xanalara baxdım. 2017-10-un p1-i (0.72%) p1 sütununda, 2017-09-un p2-si (0.55%) isə p2 sütununda ən yüksək dəyərdir. Amma 2017-08-in p3-ü (0.27%) öz sütununda orta səviyyədədir. Yəni hipotez **qismən təsdiqlənir**: Black Friday qısa müddətli geri qayıdışı artırıb, amma təsiri hər kohortda eyni deyil. Onu da qeyd etmək lazımdır ki, ən pis kohortda cəmi 3 nəfər qayıdıb, belə kiçik rəqəmlərdə təsadüfün rolu böyükdür.

## Yekun: repeat purchase güclüdür, yoxsa zəif?

**Zəifdir.** Orta ay-1 retention 0.48%-dir, ən yaxşı kohortda belə 0.72%-i keçmir, sonrakı aylarda isə 0.3%-dən aşağı qalır. Olist müştəriləri əsasən bir dəfə alış edən marketplace istifadəçiləridir.

## Tapşırıqdakı qeydlərlə fərqlər

Tapşırıqda verilən qeydlərdəki bəzi rəqəmlər bu analizlə üst-üstə düşmür. Burada bütün rəqəmlər `queries.sql`-dəki sorğulardan alınıb:
- Qeyddə ilk kohort 2016-10 (231 müştəri) göstərilib. Bu analizdə ilk kohort 2016-09-dur (1 müştəri), 2016-10-da isə 262 müştəri var.
- Qeyddə ən böyük kohort 2017-08 (5.4k) göstərilib. Burada ən böyük kohort 2017-11-dir (7,060), 2017-08-də isə 4,057 müştəri var.
- Qeyddə ortalama retention 3.2% göstərilib. Burada ay-1 retention 0.48%-dir.
- Qeyddə `order_reviews` cədvəli də birləşdirilib. Tapşırıq bunu tələb etmədiyi üçün istifadə edilmədi.


## Bonuslar

- Retention matrisi SQL-in içində conditional aggregation ilə pivot edilib (Q5, Q7), pandas-da yox.
- Retention heatmap-in diverging rəng şkalası ilə versiyası: mərkəz tipik retention səviyyəsidir (0.26%), yaşıl tipikdən yuxarı, narıncı isə aşağı deməkdir.



