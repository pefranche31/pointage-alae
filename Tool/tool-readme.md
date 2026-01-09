# Info sur l'outil de conversion pour allimenter l'outil

## Structure du csv a utiliser:


| Classe | Nom Prenom | p-lun-ma | p-lun-mi | p-lun-so | p-mar-ma | p-mar-mi | p-mar-so | p-jeu-ma | p-jeu-mi | p-jeu-so | p-ven-ma | p-ven-mi | p-ven-so | i-lun-ma | i-lun-mi | i-lun-so | i-mar-ma | i-mar-mi | i-mar-so | i-jeu-ma | i-jeu-mi | i-jeu-so | i-ven-ma | i-ven-mi | i-ven-so |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| PS | DOE Jon | | x | x | | x | x | | x | x | | x | x | | x | x | | x | x | | x | x | | x | x |
| PS | DUPONT Marie | | x | | | x | | | x | | | x | | | x | | | x | | | x | | | x | |
| MS | MARTIN Stephane | | x | | | x | | | x | | | x | | | x | | | x | | | x | | | x | |
| CP | FLECHON Emilie | | x | x | | x | x | | x | x | | x | | | x | x | | x | x | | x | x | | x | |


## Explications


- `p-lun-ma` = Semaine paire, lundi matin
- `p-mar-mi` = Semaine paire, mardi midi
- `i-jeu-so` = Semaine impaire, jeudi soir


## Fonctionnement 

- Utiliser l'outil pour convertir un csv decrivant le planning de presence (baseline) des semaines paires et imparaires
- Recuperer le JSON généré par l'outil et importez dans l'outil de pointage

