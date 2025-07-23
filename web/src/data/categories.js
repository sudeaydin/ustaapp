export const CATEGORIES = [
  {
    id: 1,
    name: 'Elektrikçi',
    icon: '⚡',
    description: 'Elektrik tesisatı ve aydınlatma hizmetleri',
    skills: [
      { id: 101, name: 'Elektrik Tesisatı', description: 'Ev ve işyeri elektrik tesisatı kurulumu ve onarımı' },
      { id: 102, name: 'LED Aydınlatma', description: 'LED aydınlatma sistemleri ve spot montajı' },
      { id: 103, name: 'Ev Otomasyonu', description: 'Akıllı ev sistemleri ve sensör kurulumu' },
      { id: 104, name: 'Panel Montajı', description: 'Elektrik panosu montajı ve bakımı' },
      { id: 105, name: 'Arıza Onarımı', description: 'Elektrik arızalarının tespiti ve onarımı' },
      { id: 106, name: 'Şalt Tesisatı', description: 'Şalt ve kumanda tesisatı kurulumu' }
    ]
  },
  {
    id: 2,
    name: 'Tesisatçı',
    icon: '🔧',
    description: 'Su, doğalgaz ve ısıtma sistemleri',
    skills: [
      { id: 201, name: 'Su Tesisatı', description: 'Temiz su ve atık su tesisatı kurulumu' },
      { id: 202, name: 'Doğalgaz Tesisatı', description: 'Doğalgaz boru tesisatı ve bağlantıları' },
      { id: 203, name: 'Kalorifer Sistemi', description: 'Merkezi ısıtma ve kalorifer sistemleri' },
      { id: 204, name: 'Klima Montajı', description: 'Split ve VRF klima sistemleri montajı' },
      { id: 205, name: 'Sıhhi Tesisat', description: 'Banyo ve mutfak sıhhi tesisat işleri' },
      { id: 206, name: 'Tıkanıklık Açma', description: 'Lavabo, tuvalet ve pis su tıkanıklığı açma' }
    ]
  },
  {
    id: 3,
    name: 'Boyacı',
    icon: '🎨',
    description: 'İç ve dış mekan boyama hizmetleri',
    skills: [
      { id: 301, name: 'İç Boyama', description: 'Ev ve ofis iç mekan boyama işleri' },
      { id: 302, name: 'Dış Boyama', description: 'Bina dış cephesi ve balkon boyama' },
      { id: 303, name: 'Dekoratif Boyama', description: 'Özel teknikler ve dekoratif boyama' },
      { id: 304, name: 'Alçı Boyama', description: 'Alçı ve sıva üzeri boyama işleri' },
      { id: 305, name: 'Ahşap Boyama', description: 'Ahşap yüzey boyama ve vernik işleri' },
      { id: 306, name: 'Metal Boyama', description: 'Demir ve metal yüzey boyama' }
    ]
  },
  {
    id: 4,
    name: 'Marangoz',
    icon: '🪚',
    description: 'Ahşap işleri ve mobilya hizmetleri',
    skills: [
      { id: 401, name: 'Mobilya Yapımı', description: 'Özel tasarım mobilya üretimi' },
      { id: 402, name: 'Kapı-Pencere', description: 'Ahşap kapı ve pencere montajı' },
      { id: 403, name: 'Dekorasyon', description: 'Ahşap dekoratif ürünler ve lambri' },
      { id: 404, name: 'Mutfak Dolabı', description: 'Mutfak dolabı yapımı ve montajı' },
      { id: 405, name: 'Parke Döşeme', description: 'Laminat ve masif parke döşeme' },
      { id: 406, name: 'Tadilat', description: 'Ahşap yapıların onarımı ve tadilat' }
    ]
  },
  {
    id: 5,
    name: 'Temizlikçi',
    icon: '🧹',
    description: 'Ev ve işyeri temizlik hizmetleri',
    skills: [
      { id: 501, name: 'Ev Temizliği', description: 'Genel ev temizliği ve düzenleme' },
      { id: 502, name: 'Ofis Temizliği', description: 'İşyeri ve ofis temizlik hizmetleri' },
      { id: 503, name: 'Cam Temizliği', description: 'Pencere ve cam yüzey temizliği' },
      { id: 504, name: 'Halı Yıkama', description: 'Halı ve koltuk yıkama hizmetleri' },
      { id: 505, name: 'Taşınma Temizliği', description: 'Taşınma öncesi/sonrası derin temizlik' },
      { id: 506, name: 'İnşaat Temizliği', description: 'İnşaat sonrası temizlik hizmetleri' }
    ]
  },
  {
    id: 6,
    name: 'Bahçıvan',
    icon: '🌱',
    description: 'Bahçe düzenleme ve peyzaj hizmetleri',
    skills: [
      { id: 601, name: 'Bahçe Düzenleme', description: 'Bahçe tasarımı ve düzenleme işleri' },
      { id: 602, name: 'Çim Ekimi', description: 'Çim ekimi ve bakım hizmetleri' },
      { id: 603, name: 'Ağaç Budama', description: 'Meyve ve süs ağaçları budama' },
      { id: 604, name: 'Peyzaj Mimarlığı', description: 'Profesyonel peyzaj tasarımı' },
      { id: 605, name: 'Sulama Sistemi', description: 'Otomatik sulama sistemleri kurulumu' },
      { id: 606, name: 'Bitki Bakımı', description: 'İç ve dış mekan bitki bakımı' }
    ]
  },
  {
    id: 7,
    name: 'Teknisyen',
    icon: '🔌',
    description: 'Elektronik cihaz onarım hizmetleri',
    skills: [
      { id: 701, name: 'Beyaz Eşya Tamiri', description: 'Buzdolabı, çamaşır makinesi tamiri' },
      { id: 702, name: 'TV-Elektronik', description: 'Televizyon ve elektronik cihaz tamiri' },
      { id: 703, name: 'Bilgisayar Tamiri', description: 'PC ve laptop donanım tamiri' },
      { id: 704, name: 'Telefon Tamiri', description: 'Akıllı telefon ekran ve donanım tamiri' },
      { id: 705, name: 'Klima Servisi', description: 'Klima bakım ve gaz dolum hizmetleri' },
      { id: 706, name: 'Anten-Uydu', description: 'Anten ve uydu sistemleri kurulum' }
    ]
  },
  {
    id: 8,
    name: 'Nakliyeci',
    icon: '🚚',
    description: 'Taşıma ve nakliye hizmetleri',
    skills: [
      { id: 801, name: 'Ev Taşıma', description: 'Evden eve nakliye hizmetleri' },
      { id: 802, name: 'Ofis Taşıma', description: 'Ofis ve işyeri taşıma hizmetleri' },
      { id: 803, name: 'Eşya Taşıma', description: 'Tek eşya ve küçük taşıma işleri' },
      { id: 804, name: 'Piyano Taşıma', description: 'Piyano ve hassas eşya taşıma' },
      { id: 805, name: 'Şehirlerarası', description: 'Şehirlerarası nakliye hizmetleri' },
      { id: 806, name: 'Ambar Hizmeti', description: 'Eşya depolama ve ambar hizmetleri' }
    ]
  }
];

// Helper functions
export const getCategoryById = (id) => {
  return CATEGORIES.find(cat => cat.id === id);
};

export const getSkillById = (skillId) => {
  for (const category of CATEGORIES) {
    const skill = category.skills.find(s => s.id === skillId);
    if (skill) {
      return { ...skill, categoryId: category.id, categoryName: category.name };
    }
  }
  return null;
};

export const getSkillsByCategory = (categoryId) => {
  const category = getCategoryById(categoryId);
  return category ? category.skills : [];
};

export const getAllSkills = () => {
  const allSkills = [];
  CATEGORIES.forEach(category => {
    category.skills.forEach(skill => {
      allSkills.push({
        ...skill,
        categoryId: category.id,
        categoryName: category.name,
        categoryIcon: category.icon
      });
    });
  });
  return allSkills;
};