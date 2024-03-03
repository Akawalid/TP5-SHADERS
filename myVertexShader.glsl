uniform mat4 transform;
uniform mat3 normalMatrix;
uniform vec3 lightNormal;
uniform mat4 texMatrix;

//la variable deform ajouté
uniform float deform;
//cette variable c'est pour faire l'animation
uniform float frame_count;

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;


void main() {
  vec4 nposition= vec4(position.x, position.y, position.z + texCoord.x * deform, position.w);
  // on modifie ici nposition
  gl_Position   = transform * nposition;
  /*
    ce que je voulais faire dans la suite est:
      .Choix de la fonction cos^4: La fonction cos^4 est choisie car elle permet d'afficher rapidement des 
      variations de couleur autour de zéro, ce qui crée un gradient rapide.
      cos^4 au voisinage de 0 VS cos:
        cos^4:
              _____________
            /             \
            |              |
        ____/                \____

        cos:
                ________
              /          \
            /              \
        __/                  \____

      on voit bien la différance mais le problème est que cos^4 garde ce comportement que entre -PI et PI
      donc il faut trouver un equivalent pour chaque angle dans [-PI, PI]
      pour le faire je passe par ces étapes:
        1.soit A un angle par exemple 17 * PI
        2.calculer le plus proche multiple de 2 * PI inférieur à A 
          2.a on le fait comme ça: 17 * PI / 2 * 2 = 8 * PI * 2 = 16 * PI
          2.b on soustrait cette valeur de notre angle A donc on obtient 17 * PI - 16 * PI = PI
          2.C c'est cette valeur qu'on va utiliser à l'interieur de cos²
      
      après ces étapes on peut dire qu'on a trouvé le model du gradient maintenant il nous reste d'ajouter les couleurs:
      . le cos^4 varie entre 0 et 1, on essaye de le varier entre 0.5 * couleur et couleur, la fonction la plus adéquate
      que j'ai trouvé après plusieurs essays est 
      vertColor = (cos^4(qualque chose) + 0.5) * color

      les étapes précédetes nous permetent d'afficher bien le gradient en couelurs, mais on n'a pas encore ajouté 
      l'effet spirale, pour le faire, il faut rendre l'angle de cos^4 non seulement dépendant de b, mais dépendant
      de a également, la formule la plus adéquate pour le faire c'est :
        float angle = texCoord.y/3.0 - 5 * texCoord.x
      pour faire quelques animations on rajoute frameCount à l'angle: 
        float angle = texCoord.y/3.0 - 5 * texCoord.x + frame_count/5.0;

  */
  float angle = texCoord.y/3.0 - 5 * texCoord.x + frame_count/5.0;
  int regulator = int(angle)/2 * 2;
  angle = angle - regulator * 3.1415;

  vertColor     = vec4(vec3(color * (pow(cos(angle), 4) + 0.5)), 1);
  vertNormal    = normalMatrix * normal;
  vertLightDir  = -lightNormal;
}