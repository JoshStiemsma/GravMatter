public class Controls {

  boolean mouseDown = false;
  boolean mouseUp = false;
  boolean mWasDown = false;
  boolean mouseClicked = false;
  boolean mouseWheeled = false;
  PVector mousePos = new PVector();


  boolean KEY_1 = false;
  boolean KEY_2 = false;
  boolean KEY_3 = false;
  
  
  boolean KEY_W = false;
  boolean KEY_A = false;
  boolean KEY_S = false;
  boolean KEY_D = false;
  boolean SPACE = false;
  boolean ScaleIn = false;
  boolean ScaleOut = false;

  void update() {
    //Check at start of frame to see if mouseDown from last frame is true
    if (mouseDown) {
      mWasDown=true;
    } else {
      mWasDown=false;
    }
    //Reset mouseClicked bool
    mouseClicked = false;
  }
  void handleMouse(PVector mPos, String state) {
    mousePos = mPos;
    switch(state) {
    case "clicked":
      mouseClicked = true;
      break;
    case "pressed":
      mouseDown = true;
      mouseUp = false;
      break;
    case "released":
      mouseUp = true;
      mouseDown = false;
      break;
    case "dragged":
      //dosomething
      break;
    }
  }


  void handleKey(int keyCode, boolean state) {
    switch(keyCode) {
      case 49:
      KEY_1 = state;
      break;
      case 50:
      KEY_2= state;
      break;
      case 51:
      KEY_3 = state;
      break;
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