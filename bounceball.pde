import http.requests.*;
//////////////////////////////
//                          //
//          write           //
//        your name         //
//                          //
//                          //
String username="Donghyeon";//
//                          //
//          here            //
//                          //
//////////////////////////////


//status init
boolean start = false;
boolean gameover= false;
boolean score_sent = false;
int score = 0;
int score_offset = 100;

//size init
float max_width = 1000;
float max_height = 600;

//text init
String score_str = "score";
float text_box_height = 100;

//block obj init
float block_width = 40;
float block_height = 20;
float margin = 3;
int max_count_width = int(max_width / (block_width + margin));
int max_count_height = 5; 
boolean[][] block_status = new boolean[max_count_width][max_count_height];

//bar obj init
float bar_width = 200;
float bar_height = 20;
float position = mouseX - bar_width / 2;

//ball obj init
float ball_position_x = position + (bar_width / 2);
float ball_position_y = max_height - 90 - bar_height;
float ball_width = 20;
float ball_direction_r = PI/2;
float ball_direction_a = 3;
float tmp_start_x = 0;
float tmp_start_y = 0;

//item obj init
float item_width = 10;
float[][] item_position = new float[100][7]; 
int item_cnt = -1;
String item_status = "";
int item_move_speed = 3;

void setup(){
  size(1000, 600);
  background(0);
  textSize(27);
  text(score_str + ":  " + score, max_width - 200, max_height - 20);
  
  for(int i = 0; i < max_count_width; i++){
    for(int j = 0; j < max_count_height; j++){
      rect(5 + i * (block_width + margin), j * (block_height + margin), block_width, block_height);
      block_status[i][j] = true;
    }
  }
  rect(position, max_height - text_box_height, bar_width, bar_height);
  ellipse(ball_position_x, ball_position_y , ball_width, ball_width);
}


void draw(){
  print(mouseX + " " + mouseY + "\n");
  clear();
  
  text(score_str + ": " + score, max_width - 200, max_height - 20);
  text(item_status, 20, max_height - 20);
  for(int i = 0; i < max_count_width; i++){
    for(int j = 0; j < max_count_height; j++){
      if(block_status[i][j]){
        rect(5 + i * (block_width + margin), 10 + j * (block_height + margin), block_width, block_height);
      }
    }
  }
  
  rect(position, max_height - text_box_height, bar_width, bar_height);
  if(start && !gameover){
    ball_position_x = tmp_start_x + ball_direction_a * (float)Math.cos(ball_direction_r);
    ball_position_y = tmp_start_y - ball_direction_a * (float)Math.sin(ball_direction_r);
    ball_position_reset();
  }
  if(!gameover){
    ellipse(ball_position_x, ball_position_y, ball_width, ball_width);
  }
  is_ball_encounted();
  move_item();
}

void mouseMoved(){
  position = mouseX - bar_width / 2;
  if(!start){
    ball_position_x = position + (bar_width / 2);
    ball_position_y = max_height - 90 - bar_height;
  }
}

void mouseClicked(){
  ball_position_reset();
  
  if(!start){
    ball_direction_a = random(3, 5);
    ball_direction_r = random(0, 1) > 0.5 ? radians(random(30, 60)) : radians(random(120, 150));
  }
  start = true;
}

void ball_position_reset(){
  tmp_start_x = ball_position_x;
  tmp_start_y = ball_position_y;
}

void is_ball_encounted(){
  if(ball_position_y < max_height / 2 && (red(get().pixels[int(ball_position_x) + int(ball_position_y - ball_width/2 - 1) * width]) == 255 || red(get().pixels[int(ball_position_x+margin+1) + int(ball_position_y - ball_width/2 - 1) * width]) == 255)){
    ball_direction_r = 2 * PI - ball_direction_r + radians(random(-5, 5));
    crashed();
  }
  else if(ball_position_y > max_height / 2 && (red(get().pixels[int(ball_position_x) + int(ball_position_y + ball_width/2 + 1) * width]) == 255 || red(get().pixels[int(ball_position_x+margin+1) + int(ball_position_y + ball_width/2 + 1) * width]) == 255)){
    ball_direction_r = 2 * PI - ball_direction_r + radians(random(-5, 5));
  }
  else if(ball_position_x - ball_width / 2 < 0 || ball_position_x + ball_width / 2 > max_width){
    ball_direction_r = PI - ball_direction_r + radians(random(-5, 5));
  }
  else if(ball_position_y > max_height - text_box_height + bar_height){
    gameover = true;
    item_status = "game over!";
    if(!score_sent){
      PostRequest post = new PostRequest("http://18.223.100.252:5000/");
      post.addData("user", username);
      post.addData("score", score+"");
      post.send();
    }
    score_sent = true;
  }
}

void crashed(){
  for(int i = 0; i < max_count_width; i++){
    if(5 + i * (block_width + margin) < ball_position_x && 5 + (i+1) * (block_width + margin) > ball_position_x){
      for(int j = max_count_height-1; j >= 0 ; j++){      
        if(block_status[i][j] == true){
          block_status[i][j] = false;
          gen_item(5 + i * (block_width + margin), j * (block_height + margin));
          score += score_offset;
          break;
        }
      }
      break;
    }
  }
}

void gen_item(float pos_x, float pos_y){
  float start_item_pos_x = pos_x + block_width / 2;
  float start_item_pos_y = pos_y + block_height + item_width / 2;
  float ran = random(0, 100);
  item_cnt++;
  if(ran < 25){//speed up
    fill(241, 95, 95);
    item_position[item_cnt][0] = 241; //r
    item_position[item_cnt][1] = 95; //g
    item_position[item_cnt][2] = 95; //b
    item_position[item_cnt][6] = 0; //item mode
    ellipse(start_item_pos_x, start_item_pos_y, item_width, item_width);
    fill(255, 255, 255);
  }
  else if(ran < 50){//speed down
    fill(0, 84, 255);
    item_position[item_cnt][0] = 0; //r
    item_position[item_cnt][1] = 84; //g
    item_position[item_cnt][2] = 255; //b
    item_position[item_cnt][6] = 1; //item mode
    ellipse(start_item_pos_x, start_item_pos_y, item_width, item_width);
    fill(255, 255, 255);
  }
  else if(ran < 75){//bar width down
    fill(29, 219, 22);
    item_position[item_cnt][0] = 29; //r
    item_position[item_cnt][1] = 219; //g
    item_position[item_cnt][2] = 22; //b
    item_position[item_cnt][6] = 2; //item mode
    ellipse(start_item_pos_x, start_item_pos_y, item_width, item_width);
    fill(255, 255, 255);
  } else{//bar width up
    fill(255, 228, 0);
    item_position[item_cnt][0] = 255; //r
    item_position[item_cnt][1] = 228; //g
    item_position[item_cnt][2] = 0; //b
    item_position[item_cnt][6] = 3; //item mode
    ellipse(start_item_pos_x, start_item_pos_y, item_width, item_width);
    fill(255, 255, 255);
  }
  item_position[item_cnt][3] = start_item_pos_x; //item_pos_x
  item_position[item_cnt][4] = start_item_pos_y; //item_pos_y
  item_position[item_cnt][5] = 1; //status that item is alive
}

void move_item(){
  for(int i = 0; i <= item_cnt; i++){
    if(item_position[i][5] == 1){
      fill(item_position[i][0], item_position[i][1], item_position[i][2]);
      ellipse(item_position[i][3], item_position[i][4], item_width, item_width);
      item_position[i][4] += item_move_speed;
      if((item_position[i][4] > (max_height - text_box_height) && item_position[i][4] < (max_height - text_box_height + bar_height)) && (item_position[i][3] > position && item_position[i][3] < position + bar_width)){
        item_position[i][5] = 0;
        item_accept(item_position[i][6]);
      }
      if(item_position[i][4] > (max_height - text_box_height + bar_height)){
        item_position[i][5] = 0;
      }
    }
  }
  fill(255, 255, 255);
}

void item_accept(float mode){
  if(mode == 0){//speed up
    float ran = random(2, 3);
    ball_direction_a += ran;
    score_offset += (int)(ran * 30);
    item_status = "Speed Up & Score Up(" + (int)(ran * 30) + ")";
  } else if(mode == 1){//speed down
    float ran = random(0, 2);
    ball_direction_a -= ran;
    score_offset -= (int)(ran * 30);
    item_status = "Speed Down & Score Down(" + (int)(ran * 30) + ")";
  } else if(mode == 2){//bar width down
    float ran = random(1, 3);
    bar_width += ran * 20;
    score_offset += (int)(ran * 30);
    item_status = "Bar Size Down & Score Up(" + (int)(ran * 30) + ")";
  } else {//bar width up
    float ran = random(1, 3);
    bar_width -= ran * 20;
    score_offset -= (int)(ran * 30);
    item_status = "Bar Size Up & Score Down(" + (int)(ran * 30) + ")";
  }
}
