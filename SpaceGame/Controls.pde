public class Controls{
  
    
  
  
boolean KEY_W = false;
boolean KEY_A = false;
boolean KEY_S = false;
boolean KEY_D = false;
boolean SPACE = false;
boolean ScaleIn = false;
boolean ScaleOut = false;

void handleKey(int keyCode, boolean state) {
  switch(keyCode) {
  case 65:
    KEY_A = state;
    break;
  case 87:
    KEY_W = state;
    break;
  case 68:
    KEY_D = state;
    break;
  case 83:
    KEY_S = state;
    break;
     case 32:
    SPACE = state;
    break;
     case 69:
    ScaleOut = state;
    break;
     case 81:
    ScaleIn = state;
    break;
  }
}

}