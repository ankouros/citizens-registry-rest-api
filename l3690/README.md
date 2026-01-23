# Τελική Εργασία l3690

## Δοχειοποίηση Εφαρμογών (Application Containerisation)

## 1. Εισαγωγή

Σκοπός της παρούσας εργασίας είναι η δοχειοποίηση (containerisation) του backend της εφαρμογής **Citizen Registry REST API**, η οποία είχε αναπτυχθεί στο πλαίσιο προηγούμενων ασκήσεων του προγράμματος.
Η εργασία υλοποιείται με τη χρήση του **Docker** και του **Docker Compose** και περιλαμβάνει:

* δοχειοποίηση της RESTful υπηρεσίας,
* χρήση δοχείου για το υποκείμενο Σύστημα Διαχείρισης Βάσεων Δεδομένων (ΣΔΒΔ),
* διαχείριση της διάταξης (deployment) μέσω scripts και docker-compose,
* εφαρμογή βασικών καλών πρακτικών ασφάλειας.

## 2. Δομή του έργου

Το έργο είναι **multi-module Maven project** και αποτελείται από τα ακόλουθα βασικά modules:

* `citizen-domain`: κοινό domain model (POJOs)
* `citizen-service`: RESTful backend υπηρεσία (**δοχειοποιείται**)
* `citizen-client`: client εφαρμογή
* `citizen-it`: integration tests

Η δοχειοποίηση αφορά **αποκλειστικά το module `citizen-service`**, καθώς αυτό αποτελεί το backend της εφαρμογής.

Όλα τα αρχεία της παρούσας άσκησης βρίσκονται στον φάκελο:

<pre class="overflow-visible! px-0!" data-start="1548" data-end="1562"><div class="contain-inline-size rounded-2xl corner-superellipse/1.1 relative bg-token-sidebar-surface-primary"><div class="sticky top-[calc(--spacing(9)+var(--header-height))] @w-xl/main:top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre!"><span><span>l3690/
</span></span></code></div></div></pre>

## 3. Dockerfile – Δοχειοποίηση RESTful Υπηρεσίας

Για τη δοχειοποίηση της RESTful υπηρεσίας χρησιμοποιείται **multi-stage Dockerfile**.

### Βασικά χαρακτηριστικά:

* Χρήση **Maven image** για το build στάδιο.
* Υποστήριξη **multi-module Maven build** (συμπεριλαμβάνεται το `citizen-domain`).
* Χρήση **JRE image** στο runtime στάδιο.
* Εκτέλεση εφαρμογής με **μη ριζικό χρήστη**.
* Μικρότερο τελικό μέγεθος εικόνας και μειωμένη επιφάνεια επιθέσεων.

Το Dockerfile βρίσκεται στο:

<pre class="overflow-visible! px-0!" data-start="2049" data-end="2073"><div class="contain-inline-size rounded-2xl corner-superellipse/1.1 relative bg-token-sidebar-surface-primary"><div class="sticky top-[calc(--spacing(9)+var(--header-height))] @w-xl/main:top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre!"><span><span>l3690/Dockerfile
</span></span></code></div></div></pre>

## 4. Scripts Διαχείρισης Docker

### 4.1 build.sh

Το script:

* κατασκευάζει την εικόνα Docker της RESTful υπηρεσίας,
* δημιουργεί Docker volume για επίμονη αποθήκευση δεδομένων της βάσης.

### 4.2 startup.sh

Το script:

* δημιουργεί οριζόμενο Docker network,
* εκκινεί δοχείο MySQL από επίσημη εικόνα του Docker Hub,
* εκκινεί δοχείο της RESTful υπηρεσίας,
* επιτρέπει την επικοινωνία των δοχείων μέσω του Docker network,
* εκθέτει **μόνο** τη θύρα της RESTful υπηρεσίας στο τοπικό σύστημα.

Η επικοινωνία με τη βάση δεδομένων γίνεται μέσω του **ονόματος του δοχείου** (`mysql-db`) και όχι μέσω `localhost`.

### 4.3 shutdown.sh

Το script:

* σταματά και καταστρέφει τα δοχεία,
* αφαιρεί το Docker network,
* **δεν διαγράφει το volume**, ώστε τα δεδομένα της βάσης να παραμένουν διαθέσιμα.

---

## 5. Docker Compose – Μοντέλο Αρχιτεκτονικής Διάταξης

Η διάταξη της εφαρμογής περιγράφεται μέσω του αρχείου:

<pre class="overflow-visible! px-0!" data-start="2987" data-end="3019"><div class="contain-inline-size rounded-2xl corner-superellipse/1.1 relative bg-token-sidebar-surface-primary"><div class="sticky top-[calc(--spacing(9)+var(--header-height))] @w-xl/main:top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre!"><span><span>l3690/docker-compose.yml
</span></span></code></div></div></pre>

### Περιλαμβάνει:

* Υπηρεσία `citizen-service` (REST API)
* Υπηρεσία `db` (MySQL)
* Οριζόμενο Docker network
* Docker volume για επίμονη αποθήκευση δεδομένων

### Εφαρμοζόμενες καλές πρακτικές ασφάλειας:

* Η βάση δεδομένων **δεν εκθέτει θύρες** στο τοπικό σύστημα.
* Η RESTful υπηρεσία εκτελείται με **read-only filesystem**.
* Χρήση `no-new-privileges`.
* Χρήση επίσημης και αξιόπιστης εικόνας MySQL.

Η διάταξη εκτελείται με:

<pre class="overflow-visible! px-0!" data-start="3449" data-end="3481"><div class="contain-inline-size rounded-2xl corner-superellipse/1.1 relative bg-token-sidebar-surface-primary"><div class="sticky top-[calc(--spacing(9)+var(--header-height))] @w-xl/main:top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-bash"><span><span>docker compose up -d
</span></span></code></div></div></pre>

και τερματίζεται με:

<pre class="overflow-visible! px-0!" data-start="3504" data-end="3535"><div class="contain-inline-size rounded-2xl corner-superellipse/1.1 relative bg-token-sidebar-surface-primary"><div class="sticky top-[calc(--spacing(9)+var(--header-height))] @w-xl/main:top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-bash"><span><span>docker compose down
</span></span></code></div></div></pre>

## 6. Επίμονη Αποθήκευση Δεδομένων

Για το ΣΔΒΔ χρησιμοποιείται Docker volume:

<pre class="overflow-visible! px-0!" data-start="3622" data-end="3645"><div class="contain-inline-size rounded-2xl corner-superellipse/1.1 relative bg-token-sidebar-surface-primary"><div class="sticky top-[calc(--spacing(9)+var(--header-height))] @w-xl/main:top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre!"><span><span>citizen-db-</span><span>data</span><span>
</span></span></code></div></div></pre>

Το volume αντιστοιχίζεται στον φάκελο:

<pre class="overflow-visible! px-0!" data-start="3686" data-end="3708"><div class="contain-inline-size rounded-2xl corner-superellipse/1.1 relative bg-token-sidebar-surface-primary"><div class="sticky top-[calc(--spacing(9)+var(--header-height))] @w-xl/main:top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre!"><span><span>/var/lib/mysql
</span></span></code></div></div></pre>

Με αυτόν τον τρόπο:

* τα δεδομένα της βάσης διατηρούνται μετά από επανεκκίνηση δοχείων,
* είναι δυνατή η επαναχρησιμοποίηση της βάσης σε νέες εκτελέσεις.
