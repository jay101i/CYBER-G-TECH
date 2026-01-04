// Mobile menu toggle
const menuToggle = document.getElementById('menuToggle');
const navMenu = document.querySelector('.menu');
menuToggle?.addEventListener('click', () => {
  if (!navMenu) return;
  const visible = getComputedStyle(navMenu).display !== 'none';
  navMenu.style.display = visible ? 'none' : 'flex';
});

// Footer year
document.getElementById('year').textContent = new Date().getFullYear();

// Local scan simulation
const form = document.getElementById('scanForm');
const resultBox = document.getElementById('scanResult');
const scoreValue = document.getElementById('scoreValue');
const riskTier = document.getElementById('riskTier');
const binaryStringEl = document.getElementById('binaryString');
const fixList = document.getElementById('fixList');

function calcScoreBinary() {
  const httpsEnabled = document.getElementById('httpsEnabled').checked ? 1 : 0;
  const spfDmarc     = document.getElementById('spfDmarc').checked ? 1 : 0;
  const twoFA        = document.getElementById('twoFA').checked ? 1 : 0;
  const pwdMgr       = document.getElementById('pwdMgr').checked ? 1 : 0;
  const backups      = document.getElementById('backups').checked ? 1 : 0;
  const breachTicked = document.getElementById('breachExposure').checked; // if exposed

  // Breach exposure: pass(1) when NOT exposed
  const breachClean  = breachTicked ? 0 : 1;

  const bits = [httpsEnabled, spfDmarc, twoFA, pwdMgr, backups, breachClean];
  const binary = bits.join('');

  // Weighted score (tune as needed)
  const weights = [20, 20, 20, 10, 10, 20]; // total 100
  const score = bits.reduce((acc, bit, i) => acc + bit * weights[i], 0);

  let tier = 'Low';
  if (score >= 80) tier = 'Low';
  else if (score >= 60) tier = 'Moderate';
  else if (score >= 40) tier = 'Elevated';
  else tier = 'High';

  return { binary, score, tier, bits };
}

function buildFixes(bits) {
  const labels = [
    'Enable HTTPS with HSTS and correct TLS configuration.',
    'Set up SPF and DMARC on your email domain to prevent spoofing.',
    'Turn on 2FA for key accounts (email, banking, admin).',
    'Adopt a password manager and unique passwords.',
    'Schedule regular backups and test restoration.',
    'Review breach exposure and rotate passwords if exposed.'
  ];
  const fixes = [];
  bits.forEach((b, i) => {
    // For breachClean bit, "0" means exposed
    if (b === 0) {
      fixes.push(labels[i]);
    }
  });
  return fixes;
}

form?.addEventListener('submit', (e) => {
  e.preventDefault();
  const id = document.getElementById('identifier').value.trim();
  if (!id) {
    alert('Please enter a domain or email.');
    return;
  }

  const { binary, score, tier, bits } = calcScoreBinary();
  scoreValue.textContent = String(score);
  riskTier.textContent = tier;
  binaryStringEl.textContent = binary;

  // Populate fixes
  fixList.innerHTML = '';
  const fixes = buildFixes(bits);
  if (fixes.length === 0) {
    const li = document.createElement('li');
    li.textContent = 'Great job! All core hygiene checks passed.';
    fixList.appendChild(li);
  } else {
    fixes.forEach((f) => {
      const li = document.createElement('li');
      li.textContent = f;
      fixList.appendChild(li);
    });
  }

  resultBox.classList.remove('hidden');
  resultBox.scrollIntoView({ behavior: 'smooth', block: 'center' });
});
