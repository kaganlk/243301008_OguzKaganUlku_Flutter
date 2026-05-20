# ToySwap - Oyuncak Paylaşım ve Takas Uygulaması

Selçuk Üniversitesi Bilgisayar Mühendisliği - Mobil Programlama Final Projesi

**Öğrenci:** [Ad Soyad]  
**Numara:** [Öğrenci No]

---

## Uygulama Hakkında

Ebeveynlerin ve çocukların oyuncaklarını takas edebildiği veya geçici olarak ödünç verebildiği bir mobil platformdur.

---

## Test Hesapları

| Rol | E-posta | Şifre |
|-----|---------|-------|
| Ebeveyn | ebeveyn@test.com | Test1234! |
| Çocuk | cocuk@test.com | Test1234! |

---

## Ekranlar

1. **Splash** - Oturum kontrolü, yönlendirme
2. **Giriş / Kayıt** - Supabase Auth, rol seçimi (Ebeveyn / Çocuk)
3. **Ana Sayfa** - Oyuncak listesi, kategori filtresi, arama
4. **Detay** - Oyuncak bilgileri, takas/ödünç talebi
5. **Oyuncak Ekle** - Fotoğraf, form, ilan yayınlama (sadece Ebeveyn)
6. **Profil** - İlanlarım, aktivite logu, çıkış
7. **Mesajlar** - Konuşma listesi
8. **Chat** - Gerçek zamanlı mesajlaşma (Supabase Realtime)

---

## Kullanılan Paketler

- `supabase_flutter` - Auth ve veritabanı
- `image_picker` - Fotoğraf yükleme
- `cached_network_image` - Resim önbellekleme
- `timeago` - Zaman gösterimi
- `uuid` - Benzersiz ID

---

## Ekran Görüntüleri

> Buraya en az 3 ekran görüntüsü ekleyin

---

## Supabase Tablo Yapısı

```sql
create table toys (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references auth.users,
  owner_name text,
  name text not null,
  category text,
  condition text,
  share_type text,
  age_group text,
  description text,
  image_url text,
  created_at timestamptz default now()
);

create table messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid references auth.users,
  receiver_id uuid references auth.users,
  toy_id uuid references toys,
  text text not null,
  created_at timestamptz default now()
);

create table requests (
  id uuid primary key default gen_random_uuid(),
  toy_id uuid references toys,
  requester_id uuid references auth.users,
  requester_name text,
  type text,
  status text default 'beklemede',
  created_at timestamptz default now()
);

create table logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users,
  action text,
  detail text,
  created_at timestamptz default now()
);
```
