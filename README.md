# TFG — Desenvolupament i Optimització d'un Model Vascular Tubular Bioimprès en 3D amb GelMA
- Autora: Ivet Jiménez González
- Grau: Enginyeria Biomèdica
- Institució: Universitat de Girona
- Col·laboració: Eurecat / TargetsLab

# Descripció
Aquest repositori conté tots els codis desenvolupats i utilitzats durant el Treball de Final de Grau sobre el Desenvolupament i Optimització d’un model vascular tubular bioimprès en 3D amb GelMA. Tots els scripts estan escrits en MATLAB i requereixen accés als fitxers de dades corresponents (imatges .jpg i taules .csv) per poder executar-se correctament.

# Contingut
* area_quadrat.m: Mesura del costat del quadrat reticulat
* area_vertex.m: Anàlisi de la cantonada arrodonida del quadrat reticulat
* barplot_area_norm.m: Gràfica de barres àrea normalitzada vs temps d'exposició UV
* barplot_area_vertex.m: Gràfica de barres àrea de vèrtex vs temps d'exposició UV
* plot_storage_modulus.m: Mòdul d'emmagatzematge (G') i pèrdua (G'') vs temperatura
* complex_viscosity.m: Viscositat complexa GelMA (7.5%, 10%, 12.5%) vs temperatura
* complex_viscosity_PVA.m: Viscositat complexa GelMA 10% amb PVA (0%, 2.5%, 5%, 7.5%)
* cell_viability.m: Anàlisi dels resultats dels assajos MTT

# Requisits
* MATLAB R2021a o superior (es recomana R2022b+)
* Toolboxes necessàries: Image Processing Toolbox (per area_quadrat.m i area_vertex.m)
* Els fitxers de dades (.csv i .jpg) han d'estar a la mateixa carpeta que els scripts, o bé cal modificar els paths corresponents dins de cada script.
