size(800, 400, P3D);

background(125);
directionalLight(255, 255, 255, 0, 1, -1);

rotateX(-0.5);
rotateY(-0.5);
translate(220, 160, 0);
box(20, 140, 20);
translate(320, 0, 0);
box(20, 140, 20);
translate(-320, 0, -160);
box(20, 140, 20);
translate(320, 0, 0);
box(20, 140, 20);
translate(-150, -80, 100);
box(320, 10, 160);
fill(128);
translate(30, -5, 30);
box(120, 2, 80);