PShape p;
PShader myShader;

void setup() {
  myShader = loadShader("myFragmentShader.glsl", "myVertexShader.glsl");
  size(800, 700, P3D);
  frameRate(20);
}

void draw() {
  shader(myShader);
  background(192);
  myShader.set("fraction", 2.5);
  
  p = createShape();
  //Ici j'utilise le mode TRIANGLE_STRIP car c'est le meuilleur mode pour faire l'interpolation de couleur, quand j'ai utilisé le mode QUAD, j'au essayé d'afficher les lignes
  //noires(foncées) mais glsl les affiches d'une manière étrange car les QUAD suivent l'incilison du ressort mais les lignes noires tournent dans le sens inverse on n'a pas assez
  //de points pour faire le gradient dans le sens inverse donc il faut changer l'alignement de ces vertex, donc il s'agit de les orienter dans le meme sens que les lignes noires et 
  //le mode TRIANGLE_STRIP fait ça parfaiment.
  p.beginShape(TRIANGLE_STRIP);
  float Rext = 150;
  float Rint = 50;
  float dA   = PI/32;
  float re   = 1.0;
  p.noStroke();
  //j'ai crée une autre varibale dans le VertexShader pour ajouter des animations de couleur.
  myShader.set("frame_count", float(frameCount));
  for (float a=-8*PI; a<8*PI; a+=dA) {
    for (float b=0; b<2*PI; b+=dA) {
      p.fill(128+a*10, 128-a*10, 255-a*10);

      float R02 = Rext*(1+cos((a+0 )/16.0))/2;
      float R13 = Rext*(1+cos((a+dA)/16.0))/2;

      float Ri02 = Rint*cos((a+0 )/16.0);
      float Ri13 = Rint*cos((a+dA)/16.0);

      PVector  p0, p1, p2, p3 ;
    
      //PVector p02 = new PVector(R02*cos(a), R02*sin(a), zP02*(cos(frameCount/5.0)+1.7));
      PVector p02 = new PVector(R02*cos(a), R02*sin(a), a/PI*(Rint+Ri02)/2*re);
      p0 = PVector.add(p02, new PVector(Ri02*sin(b)*cos(a), Ri02*sin(b)*sin(a), Ri02*cos(b)));
      //p2 = PVector.add(p02, new PVector(Ri02*sin(b+dA)*cos(a), Ri02*sin(b+dA)*sin(a), Ri02*cos(b+dA)));
      
      //PVector p13 = new PVector(R13*cos(a+dA), R13*sin(a+dA), zP13*(cos(frameCount/5.0)+1.7));
      PVector p13 = new PVector(R13*cos(a+dA), R13*sin(a+dA), (a+dA)/PI*(Rint+Ri13)/2*re);
      p1  = PVector.add(p13, new PVector(Ri13*sin(b)*cos(a+dA), Ri13*sin(b)*sin(a+dA), Ri13*cos(b)));
      //p3  = PVector.add(p13, new PVector(Ri13*sin(b+dA)*cos(a+dA), Ri13*sin(b+dA)*sin(a+dA), Ri13*cos(b+dA)));
      
      //cos est entre -1 et 1 et frameCount est croissant donc deform est entre 0 et 10
      float deform = 5 * cos(frameCount/5.0) + 5; 
      myShader.set("deform", deform);
      
/*      PVector n0 = PVector.sub(p2, p02);//origin
      n0.normalize();
      p.normal(n0.x, n0.y, n0.z);
      p.vertex(p2.x, p2.y, p2.z, a,16 * (b+dA));

      n0 = PVector.sub(p3, p13);//origin
      n0.normalize();
      p.normal(n0.x, n0.y, n0.z);
      p.vertex(p3.x, p3.y, p3.z, a+dA, 16 * (b+dA));   */
      
      //dan,s le mode TIANGLE_STRIP on n'a besoin d'afficher que P1 et P0 et dans l'itération suivante on affiche les nouveaux p0 et p1 comme p2 et p3:
      /*
      itération 0 
        P1         P0
         .          .
      itération 1:
        P1          P0
        .___________.
         \          |
          \         |
           \        |
            \       | 
             \      |
              \     |
               \    |
                \   | 
                 \  |
                  \ |
                   \|
      -> .          \.
  new P1 == P3    new P0==P2
      */
      
      //le centre est P13 et le point pour ce qu'on veut calculer la normale est p1
      PVector n0 = PVector.sub(p1, p13);//origin
      n0.normalize();
      p.normal(n0.x, n0.y, n0.z);
      p.vertex(p1.x, p1.y, p1.z, a+dA, 16 * b);
      
      n0 = PVector.sub(p0, p02);//origin
      n0.normalize();
      p.normal(n0.x, n0.y, n0.z);
      p.vertex(p0.x, p0.y, p0.z, a, 16 * b);
    }
  }
  p.endShape();
  
  
  float dirY = (mouseY / float(height) - 0.5) * 2;
  float dirX = (mouseX / float(width) - 0.5) * 2;
  directionalLight(204, 204, 204, -dirX, -dirY, -1);
  translate (width/2, height/2);
  rotateX(PI/2-frameCount*PI/500);
  rotateZ(frameCount*PI/1000);
  shape(p);
}

void keyPressed() {
  noLoop();
}
