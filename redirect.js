fetch('/allowed.json')
  .then(res => res.json())
  .then(data => {
    const path = window.location.pathname;
    const allowedPaths = [
      ...data.allowed,
      ...data.news,
      ...data.tutorial
    ];
    if (!allowedPaths.includes(path)) {
      window.location.href = '/403.html';
    }
  })
  .catch(err => {
    console.error('Fehler beim Laden der Allowed-JSON:', err);
    // Im Fehlerfall lieber sicherheitshalber weiterleiten
    window.location.href = '/403.html';
  });
