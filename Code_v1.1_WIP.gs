/**
 * POINTAGE ALAE - COEUR DU SYSTÈME (APPS SCRIPT)
 * Ce script gère les échanges entre l'interface React et le classeur Sheets.
 */

const SS = SpreadsheetApp.getActiveSpreadsheet();
const SH_BIO = SS.getSheetByName("Enfants_Bio");
const SH_POINTAGES = SS.getSheetByName("Pointages");
const SH_FLUX = SS.getSheetByName("Journal_Flux");
const SH_PLANNINGS = SS.getSheetByName("Plannings_Theoriques");
const SH_COMMENTS = SS.getSheetByName("Commentaires"); // À créer si absent

/**
 * Sert l'interface HTML
 */
function doGet() {
  return HtmlService.createTemplateFromFile('index')
    .evaluate()
    .setTitle("ALAE Pointage Hub")
    .addMetaTag('viewport', 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no')
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
}

/**
 * Récupère l'intégralité des données pour l'initialisation de l'App
 */
function getAppData() {
  try {
    const dataBio = SH_BIO.getDataRange().getValues();
    const headersBio = dataBio.shift();
    
    // 1. Liste des enfants
    const children = dataBio.map(row => ({
      id: row[0],
      nom: row[1],
      prenom: row[2],
      classe: row[3],
      niveau: row[4]
    })).filter(c => c.id);

    // 2. Matrice de pointage
    // On récupère tout à partir de la ligne 1 pour avoir dates et créneaux
    const dataPointages = SH_POINTAGES.getDataRange().getValues();
    const datesRow = dataPointages[0];
    const creneauxRow = dataPointages[1];
    
    const attendanceMap = {};
    // On boucle sur les lignes (enfants) à partir de la ligne 3 (index 2)
    for (let i = 2; i < dataPointages.length; i++) {
      const row = dataPointages[i];
      const childId = row[0];
      // On boucle sur les colonnes de données à partir de la colonne D (index 3)
      for (let j = 3; j < row.length; j++) {
        if (row[j] === "x") {
          const dateStr = Utilities.formatDate(new Date(datesRow[j]), Session.getScriptTimeZone(), "dd/MM/yyyy");
          const creneau = creneauxRow[j];
          attendanceMap[`${dateStr}-${childId}-${creneau}`] = "present";
        }
      }
    }

    // 3. Journal des flux (Entrées/Sorties)
    const dataFlux = SH_FLUX.getDataRange().getValues();
    dataFlux.shift(); // remove headers
    const reports = dataFlux.map(row => ({
      date: Utilities.formatDate(new Date(row[1]), Session.getScriptTimeZone(), "dd/MM/yyyy"),
      childId: row[2],
      type: row[3], // ARRIVEE ou DEPART
      creneau: row[4],
      time: Utilities.formatDate(new Date(row[0]), Session.getScriptTimeZone(), "HH:mm")
    }));

    return {
      children,
      attendance: attendanceMap,
      reports,
      serverTime: new Date().toISOString()
    };
  } catch (e) {
    throw new Error("Erreur de lecture des données : " + e.message);
  }
}

/**
 * Enregistre ou supprime une présence "Administrative" (la croix dans la matrice)
 */
function togglePresence(dateStr, childId, creneau) {
  const data = SH_POINTAGES.getDataRange().getValues();
  const datesRow = data[0];
  const creneauxRow = data[1];
  
  // Trouver la colonne
  let colIndex = -1;
  for (let j = 3; j < datesRow.length; j++) {
    const d = Utilities.formatDate(new Date(datesRow[j]), Session.getScriptTimeZone(), "dd/MM/yyyy");
    if (d === dateStr && creneauxRow[j].toLowerCase() === creneau.toLowerCase()) {
      colIndex = j + 1;
      break;
    }
  }
  
  // Trouver la ligne
  let rowIndex = -1;
  for (let i = 2; i < data.length; i++) {
    if (data[i][0] == childId) {
      rowIndex = i + 1;
      break;
    }
  }
  
  if (colIndex > 0 && rowIndex > 0) {
    const cell = SH_POINTAGES.getRange(rowIndex, colIndex);
    const newValue = cell.getValue() === "x" ? "" : "x";
    cell.setValue(newValue);
    return newValue === "x" ? "present" : null;
  }
  throw new Error("Cellule non trouvée pour " + childId + " le " + dateStr);
}

/**
 * Enregistre un mouvement physique dans le journal
 */
function logMouvement(childId, type, creneau, dateStr) {
  const now = new Date();
  SH_FLUX.appendRow([
    now,
    new Date(dateStr.split('/').reverse().join('-')), // Conversion DD/MM/YYYY vers Date
    childId,
    type, // ARRIVEE ou DEPART
    creneau
  ]);
  return Utilities.formatDate(now, Session.getScriptTimeZone(), "HH:mm");
}