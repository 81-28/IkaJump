
import processing.sound.*;
// import java.io.File;
import java.util.Collections;
import java.util.Comparator;
import java.util.Set;
// import java.util.List;
// import java.util.Map;

HashMap<String, SoundFile> sounds = new HashMap<String, SoundFile>();
HashMap<String, PImage> images = new HashMap<String, PImage>();
ArrayList<JSONObject> stages = new ArrayList<JSONObject>();
String folderPath;
// folderPath = sketchPath("STAGESs"); setupで設定,相対パスにするとエラー
JSONObject stagess = new JSONObject();
ArrayList<JSONObject> allStages = new ArrayList<JSONObject>();
JSONObject templateStage;
JSONObject templateItems;

boolean isFocusStages = false;
ArrayList<String> jsonNames = new ArrayList<String>();
int selectedJsonNum = 0;
String selectedJsonName = "";
ArrayList<String> stageNames = new ArrayList<String>();
int selectedStageNum = 0;
String selectedStageName = "";

int fps = 60;
int waitFrame = 0;
boolean[] keys = new boolean[128];
String inputString = "";
String inputPlace = "";
boolean leftMousePressed = false;
boolean rightMousePressed = false;
float mousePX = 0;
float mousePY = 0;
float mouseVX = 0;
float mouseVY = 0;
final int keyCoolFrame = fps/6;
int keyCoolCount = keyCoolFrame;
color bgColor = color(31, 31, 95);
color gameBGColor = color(31, 31, 95);
// 40block
int sketchWidth = 800;
int sketchHeight = 700;
int totalHeight = sketchHeight * 4;
float baseY = totalHeight - sketchHeight;
int ballSize = 40;
int blockSize = ballSize/2;

final int GAME = 0;
final int PAUSE = 1;
final int GOAL = 2;
final int DEAD = 3;
final int MAIN = 4;
final int MENU = 5;
final int STAGEMENU = 6;
final int EDITMENU = 7;
final int EDIT = 8;
final int EDITGAME = 9;
final int EDITINFO = 10;
final int EDITDEAD = 11;
final int ITEMINFO = 12;
int scene = MAIN;
int pastScene = MAIN;

boolean firstEditLoad = true;

int selectedMainNum = 0;
ArrayList<JSONObject> mainMenuStrings = new ArrayList<JSONObject>();
int selectedStageMenuNum = 0;
float stageMenuBaseY = 0;
ArrayList<String> stageMenuStrings = new ArrayList<String>();
int selectedJsonMenuNum = 0;
float jsonMenuBaseY = 0;
ArrayList<String> jsonMenuStrings = new ArrayList<String>();

int allStageNum = 0;
int stageNum = 0;
int maxStageNum = 0;
int baseJumpCount = 1;


void loadJSONs() {
    // String folderPath = sketchPath("STAGESs");
    File folder = new File(folderPath);

    stagess = new JSONObject();
    ArrayList<JSONObject> loadedStages = new ArrayList<JSONObject>();

    if (folder != null && folder.isDirectory()) {
        File[] listOfFiles = folder.listFiles();
        for (File file : listOfFiles) {
            if (file.isFile() && file.getName().endsWith(".json")) {
                String filePath = file.getAbsolutePath();
                String fileName = file.getName();
                String name = fileName.substring(0, fileName.length() - 5);
                JSONObject jsonObject = loadJSONObject(filePath);

                Set<String> keys = jsonObject.keys();
                for (String key : keys) {
                    // JSONObject originalStage = jsonObject.getJSONObject(key);
                    // JSONObject stage = JSONObject.parse(originalStage.toString());
                    JSONObject stage = jsonObject.getJSONObject(key);
                    stage.setString("stageName", key);
                    loadedStages.add(stage);
                }

                stagess.setJSONObject(name, jsonObject);

                println("Loaded and merged: " + file.getName());
            }
        }


        // println(stagess);

        // String savePath = folderPath + "/merged.json";
        // saveJSONObject(stagess, savePath);
        // println("Merged JSON saved as merged.json");
        jsonNames = new ArrayList<String>(stagess.keys());
        println(jsonNames);
        stageNames = new ArrayList<String>(stagess.getJSONObject(jsonNames.get(0)).keys());
        // for (int i = 0; i < jsonNames.size(); i++) {
        //     JSONObject stage = stagess.getJSONObject(jsonNames.get(i));
        //     // stageNames.add(stage.getString("stageName"));
        //     stageNames = new ArrayList<String>(stage.keys());
        //     println(stageNames);
        // }


        Collections.sort(loadedStages, new Comparator<JSONObject>() {
            public int compare(JSONObject a, JSONObject b) {
                return a.getInt("difficulty") - b.getInt("difficulty");
            }
        });
        // for (int i = 0; i < loadedStages.size(); i++) {
        //     JSONObject stage = loadedStages.get(i);
        //     allStages.add(stage);
        // }

        allStages = new ArrayList<JSONObject>(loadedStages);
        // println(allStages);

        // String newSavePath = folderPath + "/allStages.json";
        // saveJSONArray(allStages, newSavePath);
        // println("Merged JSON saved as allStages.json");


        // 保存テストok
        // JSONObject json_1 = stagess.getJSONObject("stageJSON1");
        // JSONObject json_2 = stagess.getJSONObject("stageJSON2");
        // JSONObject newJson = json_2.getJSONObject("stage2");
        // newJson.setInt("difficulty", 100);
        // json_2.remove("stage2");
        // json_1.setJSONObject("stage2", newJson);
        // String savePath_1 = folderPath + "/stageJSON1.json";
        // saveJSONObject(json_1, savePath_1);
        // String savePath_2 = folderPath + "/stageJSON2.json";
        // saveJSONObject(json_2, savePath_2);

    } else {
        println("folder is null or not a directory");
    }
}

void keyPressed() {
    if (key < 128) {
        keys[key] = true;
    }
    if (keyCode == UP || keyCode == DOWN || keyCode == LEFT || keyCode == RIGHT || keyCode == 32) {
        keys[keyCode] = true;
    }
    if (key == ESC) {
        if (scene == MAIN) {
            exit();
        } else {
            key = 0;
        }
    }
    if (scene == EDITINFO && !(key == CODED || key == ENTER || key == RETURN)) {
        if (key == BACKSPACE) {
            editingStage.deleteInfoString();
        } else {
            editingStage.setInfo(key);
        }
    }
    if (scene == ITEMINFO && !(key == CODED || key == ENTER || key == RETURN)) {
        if (key == BACKSPACE) {
            editingStage.deleteItemInfoString();
        } else {
            editingStage.setItemInfo(key);
        }
    }
}

void keyReleased() {
    if (key < 128) {
        keys[key] = false;
    }
    if (keyCode == UP || keyCode == DOWN || keyCode == LEFT || keyCode == RIGHT || keyCode == 32) {
        keys[keyCode] = false;
    }
}

void mousePressed() {
    if (mouseButton == LEFT) {
        leftMousePressed = true;
    }
    if (mouseButton == RIGHT) {
        rightMousePressed = true;
    }
}

void mouseReleased() {
    if (mouseButton == LEFT) {
        leftMousePressed = false;
    }
    if (mouseButton == RIGHT) {
        rightMousePressed = false;
    }
}

void mouseWheel(MouseEvent event) {
    int e = event.getCount();
    if (scene == MENU) {
        if (mouseY >= height/4) {
            if (mouseX < width/3) {
                jsonMenuBaseY += e * 20;
            } else if (mouseX < width*2/3) {
                stageMenuBaseY += e * 20;
            }
        }
    }
    if (scene == EDIT) {
        float pastCollisionYStart = editingStage.collisionYStart;
        float pastCollisionYEnd = editingStage.collisionYEnd;
        float pastBaseY = baseY;
        baseY += e * 20;
        if (baseY < 0) {
            baseY = 0;
        } else if (baseY > totalHeight - height) {
            baseY = totalHeight - height;
        }
        editingStage.collisionYStart = pastCollisionYStart + (pastBaseY - baseY);
        editingStage.collisionYEnd = pastCollisionYEnd + (pastBaseY - baseY);
        editingStage.setColPos();
    }
}

void adjustMenuBaseY() {
    float nowStageMenuY = height/4 + 50*(selectedStageNum+1) - stageMenuBaseY;
    if (nowStageMenuY < height/4 + 100) {
        stageMenuBaseY = 50*(selectedStageNum+1) - 100;
    } else if (nowStageMenuY > height - 75) {
        stageMenuBaseY = 50*(selectedStageNum+1) - height*3/4 + 75;
    }
    float nowJsonMenuY = height/4 + 50*(selectedJsonNum+1) - jsonMenuBaseY;
    if (nowJsonMenuY < height/4 + 100) {
        jsonMenuBaseY = 50*(selectedJsonNum+1) - 100;
    } else if (nowJsonMenuY > height - 75) {
        jsonMenuBaseY = 50*(selectedJsonNum+1) - height*3/4 + 75;
    }
}

class Player {
    String status = "alive";
    float x, y;
    float px, py;
    float vx = 0, vy = 0;
    float maxVelocity = 3;
    float gravity = 0.5;
    int size =  ballSize;
    int radius = size / 2;
    float maxJump = 21;
    int jumpCount = baseJumpCount;
    int chargeFrame = 0;
    int fullChargeFrame = fps/2;

    Player(float x, float y) {
        this.x = x;
        this.y = y;
        this.px = this.x;
        this.py = this.y;
    }

    void move(int right) {
        if (right == 0) {
            vx = 0;
            return;
        }
        if (vy != 0 && status == "alive") {
            if (chargeFrame > 0) {
                vx += maxVelocity * right * 0.5;
            } else {
                vx = maxVelocity * right;
            }
        }
    }

    void chargeJump() {
        if (status == "alive") {
            chargeFrame++;
        }
    }

    void jump() {
        if (chargeFrame != 0 && jumpCount > 0 && status == "alive") {
            sounds.get("jump").play();
            vy = -maxJump * ((float)min(chargeFrame, fullChargeFrame) / fullChargeFrame);
            jumpCount--;
        }
        chargeFrame = 0;
    }

    void goal() {
        sounds.get("clear").play();
        if (scene == GAME) {
            pastScene = scene;
            scene = GOAL;
        } else if (scene == EDITGAME) {
            pastScene = scene;
            scene = EDIT;
        }
        stageNum++;
        if (selectedMainNum == 0 || selectedMainNum == 1) {
            allStageNum = stageNum;
        }
        if (stageNum > maxStageNum) {
            stageNum = 0;
        }
    }

    void dead() {
        sounds.get("dead").play();
        vy = 0;
        status = "dead";
        if (scene == GAME) {
            pastScene = scene;
            scene = DEAD;
        } else if (scene == EDITGAME) {
            pastScene = scene;
            scene = EDITDEAD;
        }
    }

    void update() {
        if (status == "alive") {
            vy += gravity;
        }
        if (vy > 0) {
            vy = min(vy, maxVelocity*8);
        } else {
            vy = max(vy, -maxVelocity*8);
        }
        px = x;
        py = y;
        y += vy;
        x += vx;
        if (x < 0) {
            x += width;            
        } else if (x > width) {
            x -= width;
        }
        if (y > totalHeight - radius) {
            y = totalHeight - radius;
            vy = 0;
        }
        
        if (y < height*3/5) {
            baseY = 0;
        } else if (y > totalHeight - height*2/5) {
            baseY = totalHeight - height;
        } else {
            baseY = y - height*3/5;
        }
    }

    void display() {
        float drawY = y - baseY;
        if (-radius < drawY && drawY < height + radius) {
            if (status == "dead") {
                image(images.get("dead"), x - radius, drawY - radius, size, size);
            } else {
                if (chargeFrame == 0) {
                    image(images.get("ika"), x - radius, drawY - radius, size, size);
                } else if (chargeFrame < fullChargeFrame/3) {
                    image(images.get("charge1"), x - radius, drawY - radius, size, size);
                } else if (chargeFrame < fullChargeFrame*2/3) {
                    image(images.get("charge2"), x - radius, drawY - radius, size, size);
                } else if (chargeFrame < fullChargeFrame) {
                    image(images.get("charge3"), x - radius, drawY - radius, size, size);
                } else {
                    int re = (chargeFrame - fullChargeFrame)/4 % 4;
                    switch (re) {
                        case 0:
                            image(images.get("charge4"), x - radius, drawY - radius, size, size);
                            break;
                        case 1:
                            image(images.get("charge5"), x - radius, drawY - radius, size, size);
                            break;
                        case 2:
                            image(images.get("charge6"), x - radius, drawY - radius, size, size);
                            break;
                        case 3:
                            image(images.get("charge5"), x - radius, drawY - radius, size, size);
                            break;
                    }
                }
            }
        }
    }
}

abstract class Item {
    boolean exists = true;
    float x, y;
    int size = ballSize;
    int radius = size / 2;
    String imageName = "fish";

    Item(float x, float y) {
        this.x = x;
        this.y = y;
    }

    void collision(Player player) {
        if (exists && dist(player.x, player.y, x, y) < player.radius + radius) {
            exists = false;
            event(player);
        }
    }
    abstract void event(Player player);

    void display() {
        if (exists || imageName == "goal") {
            float drawY = y - baseY;
            if (-radius < drawY && drawY < height + radius) {
                image(images.get(imageName), x - radius, drawY - radius, size, size);
            }
        }
    
    }
}

class GoalItem extends Item {
    GoalItem(float x, float y) {
        super(x, y);
        this.imageName = "goal";
    }

    void event(Player player) {
        player.goal();
    }
}

class BoostItem extends Item {
    BoostItem(float x, float y) {
        super(x, y);
        this.imageName = "fish";
    }

    void event(Player player) {
        sounds.get("fish").play();
        player.vy = -player.maxJump;
    }
}

class Star {
    float x, y, size;

    Star() {
        x = random(width);
        y = random(height);
        size = random(1, 3);
    }
    
    void display(float addY) {
        float drawY = y - baseY + addY;
        if (-size < drawY && drawY < height + size) {
            fill(127, 95, 159);
            ellipse(x, drawY, size, size);
        }
    }
}

class Platform {
    float x, y, px, py, vx = 0, vy = 0;
    int w;
    color c = color(127, 63, 0);
    String imageName = "block";
    Platform(float x, float y, int w) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.px = this.x;
        this.py = this.y;
    }

    void collision(Player player) {
        float virtualX = x;
        if (virtualX < 0) {
            while (virtualX < 0) {
                virtualX += width;
            }
        } else if (virtualX >= width) {
            while (virtualX >= width) {
                virtualX -= width;
            }
        }
        if ((player.py + player.radius <= py && y < player.y + player.radius) && ((virtualX < player.x + player.radius && player.x - player.radius < virtualX + blockSize*w) || (virtualX - width < player.x + player.radius && player.x - player.radius < virtualX + blockSize*w - width))) {
            event(player);
        }
    }
    void event(Player player) {
        player.y = this.y - player.radius;
        player.vy = 0;
        player.x += this.vx;
        player.jumpCount = baseJumpCount;
    }

    void update() {
        px = x;
        py = y;
        x += vx;
        y += vy;
    }

    void display() {
        float drawY = y - baseY;
        float virtualX = x;
        if (virtualX < 0) {
            while (virtualX < 0) {
                virtualX += width;
            }
        } else if (virtualX >= width) {
            while (virtualX >= width) {
                virtualX -= width;
            }
        }
        float endX = virtualX + blockSize*w;
        if (-blockSize < drawY && drawY < height) {
            for (int i = 0; i < w; i++) {
                image(images.get(imageName), virtualX + blockSize*i, drawY, blockSize, blockSize);
            }
            if (endX > width) {
                for (int i = 0; i < w; i++) {
                    image(images.get(imageName), virtualX - width + blockSize*i, drawY, blockSize, blockSize);
                }
            }
        }
    }
}

class MovePlatform extends Platform {
    float x0, rangeX;
    MovePlatform(float x, float y, int w, float vx, float rangeX) {
        super(x, y, w);
        this.x0 = x;
        this.vx = vx;
        this.rangeX = rangeX;
        // this.c = color(127, 127, 255);
        this.imageName = "jerry";
    }

    void update() {
        px = x;
        x += vx;
        if (x > x0 + rangeX) {
            x = - x + (x0 + rangeX)*2;
            vx = -vx;
        } else if (x < x0) {
            x = - x + x0*2;
            vx = -vx;
        }

        // if (x < 0) {
        //     x += width;
        // } else if (x > width) {
        //     x -= width;
        // }
    }
}

class Acid extends Platform {
    Acid(float y, float vy) {
        super(0, y, width/blockSize);
        this.vy = -vy;
        this.c = color(111, 31, 159);
    }

    void event(Player player) {
        vy = 0;
        player.dead();
    }

    void display() {
        float drawY = y - baseY;
        if (-blockSize < drawY && drawY < height) {
            fill(c);
            rect(0, drawY+blockSize/2, width, height);
            for (int i = 0; i < w; i++) {
                image(images.get("acid"), blockSize*i, drawY, blockSize, blockSize);
            }
        }
    }
}

class EditingStage {
    JSONObject nowStage;
    ArrayList<JSONObject> selectedEditingItem = new ArrayList<JSONObject>();
    float collisionXStart, collisionYStart, collisionXEnd, collisionYEnd;
    float leftCollisionXStart, leftCollisionXEnd, rightCollisionXStart, rightCollisionXEnd;
    String[] addTypes = {"platform", "movePlatform", "boostItem"};
    String addType = "platform";
    String newJsonName = "";
    String newStageName = "";

    int newStageDifficulty = 0;
    String newStageAuthor = "";
    String newBGColor = "";
    int newHeight = 0;

    String acidY = "-8000.0";
    String acidVY = "1.0";

    int stageInfoNum = 0;

    ArrayList<ArrayList<String>> itemInfoStrings = new ArrayList<ArrayList<String>>();
    int itemInfoNum = 0;
    int itemInfoMax = 0;

    EditingStage(JSONObject stage) {
        this.nowStage = JSONObject.parse(stage.toString());
        newJsonName = selectedJsonName;
        newStageName = selectedStageName;

        newStageDifficulty = nowStage.getInt("difficulty");
        newStageAuthor = nowStage.getString("author");
        newBGColor = nowStage.getString("bgColor").substring(1);
        newHeight = nowStage.getInt("height");

        acidY = str(nowStage.getJSONObject("acid").getFloat("y"));
        acidVY = str(nowStage.getJSONObject("acid").getFloat("vy"));

        // println("nowStage");
        // println(nowStage);
    }

    void setInfo(char key) {
        String input = str(key);
        String nowString = "";
        String pastString = "";
        switch (stageInfoNum) {
            case 0:
                nowString = newJsonName;
                nowString += input;
                newJsonName = nowString;
                break;
            case 1:
                nowString = newStageName;
                nowString += input;
                newStageName = nowString;
                break;
            case 2:
                nowString = str(newStageDifficulty);
                if ('0' <= key && key <= '9') {
                    // 
                } else {
                    input = "";
                }

                nowString += input;
                newStageDifficulty = int(nowString);
                break;
            case 3:
                nowString = newStageAuthor;
                nowString += input;
                newStageAuthor = nowString;
                break;
            case 4:
                nowString = newBGColor;
                if (('0' <= key && key <= '9') || ('a' <= key && key <= 'f') || ('A' <= key && key <= 'F')) {
                    // 
                } else {
                    input = "";
                }

                if (nowString.length() < 6) {
                    nowString += input;
                    newBGColor = nowString;
                }
                break;
            case 5:
                nowString = str(newHeight);
                if ('0' <= key && key <= '9') {
                    // 
                } else {
                    input = "";
                }

                nowString += input;
                newHeight = int(nowString);
                break;
            case 6:
                nowString = acidY;
                pastString = nowString;
                if (('0' <= key && key <= '9') || key == '.' || key == '-') {
                    // 
                } else {
                    input = "";
                }

                nowString += input;
                if (!nowString.matches("-?[0-9]*\\.?[0-9]*")) {
                    nowString = pastString;
                    println("not match");
                }
                acidY = nowString;
                break;
            case 7:
                nowString = acidVY;
                pastString = nowString;
                if (('0' <= key && key <= '9') || key == '.' || key == '-') {
                    // 
                } else {
                    input = "";
                }

                nowString += input;
                if (!nowString.matches("-?[0-9]*\\.?[0-9]*")) {
                    nowString = pastString;
                    println("not match");
                }
                acidVY = nowString;
                break;
        }
    }

    void deleteInfoString() {
        String nowString = "";
        switch (stageInfoNum) {
            case 0:
                newJsonName = newJsonName.substring(0, max(0, newJsonName.length()-1));
                break;
            case 1:
                newStageName = newStageName.substring(0, max(0, newStageName.length()-1));
                break;
            case 2:
                newStageDifficulty = int(str(newStageDifficulty).substring(0, max(0, str(newStageDifficulty).length()-1)));
                break;
            case 3:
                newStageAuthor = newStageAuthor.substring(0, max(0, newStageAuthor.length()-1));
                break;
            case 4:
                newBGColor = newBGColor.substring(0, max(0, newBGColor.length()-1));
                break;
            case 5:
                newHeight = int(str(newHeight).substring(0, max(0, str(newHeight).length()-1)));
                break;
            case 6:
                acidY = acidY.substring(0, max(0, acidY.length()-1));
                break;
            case 7:
                acidVY = acidVY.substring(0, max(0, acidVY.length()-1));
                break;
        }
    }

    void fixStageInfo() {
        if (newJsonName.length() == 0) {
            newJsonName = "newJson";
        }
        if (newStageName.length() == 0) {
            newStageName = "newStage";
        }
        if (!str(newStageDifficulty).matches("[0-9]+")) {
            newStageDifficulty = nowStage.getInt("difficulty");
        }
        if (newStageAuthor.length() == 0) {
            newStageAuthor = "unknown";
        }
        if (!newBGColor.matches("[0-9a-fA-F]{6}")) {
            newBGColor = nowStage.getString("bgColor").substring(1);
        }
        if (!str(newHeight).matches("[0-9]+")) {
            newHeight = nowStage.getInt("height");
        }
        if (!acidY.matches("-?[0-9]+(\\.[0-9]+)?")) {
            acidY = str(nowStage.getJSONObject("acid").getFloat("y"));
        }
        if (!acidVY.matches("-?[0-9]+(\\.[0-9]+)?")) {
            acidVY = str(nowStage.getJSONObject("acid").getFloat("vy"));
        }
        println("fixed");
    }

    void reloadItemInfo(JSONObject selectedItem) {
        selectedItem = JSONObject.parse(selectedItem.toString());
        selectedItem.remove("colPos");
        selectedItem.remove("type");
        itemInfoNum = 0;
        itemInfoMax = selectedItem.keys().size();

        itemInfoStrings.clear();
        ArrayList<String> keys = new ArrayList<String>(selectedItem.keys());
        for (int i = 0; i < keys.size(); i++) {
            ArrayList<String> stringPair = new ArrayList<String>();
            String key = keys.get(i);
            println(key);
            String value;
            if (key.equals("w") || key.equals("jumpCount")) {
                value = str(selectedItem.getInt(key));
                println("int");
            } else {
                value = str(selectedItem.getFloat(key));
            }
            stringPair.add(key);
            stringPair.add(value);
            itemInfoStrings.add(stringPair);
        }
        println(itemInfoStrings);
    }

    void setItemInfo(char key) {
        String input = str(key);
        String index = itemInfoStrings.get(itemInfoNum).get(0);
        String pastString = itemInfoStrings.get(itemInfoNum).get(1);
        String nowString = pastString;
        if (index.equals("w") || index.equals("jumpCount")) {
            if ('0' <= key && key <= '9') {
                // 
            } else {
                input = "";
            }
            nowString += input;
        } else {
            if (('0' <= key && key <= '9') || key == '.' || key == '-') {
                // 
            } else {
                input = "";
            }
            nowString += input;
            if (!nowString.matches("-?[0-9]*\\.?[0-9]*")) {
                nowString = pastString;
                println("not match");
            }
        }
        itemInfoStrings.get(itemInfoNum).set(1, nowString);
    }

    void deleteItemInfoString() {
        String nowString = itemInfoStrings.get(itemInfoNum).get(1);
        nowString = nowString.substring(0, max(0, nowString.length()-1));
        itemInfoStrings.get(itemInfoNum).set(1, nowString);
    }

    void saveItemInfo() {
        JSONObject selectedItem = selectedEditingItem.get(0);
        for (int i = 0; i < itemInfoStrings.size(); i++) {
            String index = itemInfoStrings.get(i).get(0);
            String nowString = itemInfoStrings.get(i).get(1);
            if (index.equals("w") || index.equals("jumpCount")) {
                if (!nowString.matches("[0-9]+") || nowString.matches("0+")) {
                    nowString = str(selectedItem.getInt(index));
                }
                itemInfoStrings.get(i).set(1, nowString);
                selectedEditingItem.get(0).setInt(index, int(nowString));
            } else {
                if (!nowString.matches("-?[0-9]+(\\.[0-9]+)?")) {
                    nowString = str(selectedItem.getFloat(index));
                }
                itemInfoStrings.get(i).set(1, nowString);
                selectedEditingItem.get(0).setFloat(index, float(nowString));
            }
        }
        JSONObject newSelectedItem = JSONObject.parse(selectedEditingItem.get(0).toString());
        String type = newSelectedItem.getString("type");
        if (type.equals("player") || type.equals("goal") || type.equals("boostItem")) {
            collisionXStart = newSelectedItem.getFloat("x")-blockSize;
            collisionYStart = totalHeight - newSelectedItem.getFloat("y") - baseY - blockSize;
            collisionXEnd = collisionXStart + ballSize;
            collisionYEnd = collisionYStart + ballSize;
        } else if (type.equals("platform") || type.equals("movePlatform") || type.equals("acid")) {
            collisionXStart = newSelectedItem.getFloat("x");
            collisionYStart = totalHeight - newSelectedItem.getFloat("y") - baseY;
            collisionXEnd = collisionXStart + blockSize*newSelectedItem.getInt("w");
            collisionYEnd = collisionYStart + blockSize;
        }
        setColPos();
    }

    void switchAddType() {
        // if (addType.equals("platform")) {
        //     addType = "movePlatform";
        // } else if (addType.equals("movePlatform")) {
        //     addType = "boostItem";
        // } else if (addType.equals("boostItem")) {
        //     addType = "platform";
        // }
        int index = 0;
        for (int i = 0; i < addTypes.length; i++) {
            if (addTypes[i].equals(addType)) {
                index = i;
                break;
            }
        }
        index++;
        if (index >= addTypes.length) {
            index = 0;
        }
        addType = addTypes[index];
    }

    void setColPos() {
        float meanCollisionX = (collisionXStart + collisionXEnd) / 2;
        if (meanCollisionX < 0) {
            collisionXStart += width;
            collisionXEnd += width;
        } else if (meanCollisionX >= width) {
            collisionXStart -= width;
            collisionXEnd -= width;
        }
        leftCollisionXStart = collisionXStart - width;
        leftCollisionXEnd = collisionXEnd - width;
        rightCollisionXStart = collisionXStart + width;
        rightCollisionXEnd = collisionXEnd + width;
        if (selectedEditingItem.size() > 0) {
            JSONObject colPos = new JSONObject();
            colPos.setFloat("collisionXStart", collisionXStart);
            colPos.setFloat("collisionYStart", collisionYStart);
            colPos.setFloat("collisionXEnd", collisionXEnd);
            colPos.setFloat("collisionYEnd", collisionYEnd);
            colPos.setFloat("leftCollisionXStart", leftCollisionXStart);
            colPos.setFloat("leftCollisionXEnd", leftCollisionXEnd);
            colPos.setFloat("rightCollisionXStart", rightCollisionXStart);
            colPos.setFloat("rightCollisionXEnd", rightCollisionXEnd);
            selectedEditingItem.get(0).setJSONObject("colPos", colPos);
        }

        // println("selectedEditingItem");
        // println(selectedEditingItem);
    }

    void editMove (int right, int down) {
        if (selectedEditingItem.size() > 0) {
            collisionXStart = selectedEditingItem.get(0).getJSONObject("colPos").getFloat("collisionXStart");
            collisionYStart = selectedEditingItem.get(0).getJSONObject("colPos").getFloat("collisionYStart");
            collisionXEnd = selectedEditingItem.get(0).getJSONObject("colPos").getFloat("collisionXEnd");
            collisionYEnd = selectedEditingItem.get(0).getJSONObject("colPos").getFloat("collisionYEnd");
            collisionXStart += right;
            collisionYStart += down;
            collisionXEnd += right;
            collisionYEnd += down;
            float meanCollisionX = (collisionXStart + collisionXEnd) / 2;
            if (meanCollisionX < 0) {
                collisionXStart += width;
                collisionXEnd += width;
                selectedEditingItem.get(0).setFloat("x", selectedEditingItem.get(0).getFloat("x")+right+width);
            } else if (meanCollisionX >= width) {
                collisionXStart -= width;
                collisionXEnd -= width;
                selectedEditingItem.get(0).setFloat("x", selectedEditingItem.get(0).getFloat("x")+right-width);
            } else {
                selectedEditingItem.get(0).setFloat("x", selectedEditingItem.get(0).getFloat("x")+right);
            }
            selectedEditingItem.get(0).setFloat("y", selectedEditingItem.get(0).getFloat("y")-down);
            setColPos();
        }
    }

    void collision() {
        if (scene == EDIT) {
            if (selectedEditingItem.size() == 0) {
                if (leftMousePressed || rightMousePressed) {
                    collisionXStart = nowStage.getJSONObject("player").getFloat("x")-blockSize;
                    collisionYStart = totalHeight - nowStage.getJSONObject("player").getFloat("y") - baseY - blockSize;
                    collisionXEnd = collisionXStart + ballSize;
                    collisionYEnd = collisionYStart + ballSize;
                    leftCollisionXStart = collisionXStart - width;
                    leftCollisionXEnd = collisionXEnd - width;
                    rightCollisionXStart = collisionXStart + width;
                    rightCollisionXEnd = collisionXEnd + width;
                    if (((collisionXStart <= mouseX && mouseX < collisionXEnd) || (leftCollisionXStart <= mouseX && mouseX < leftCollisionXEnd) || (rightCollisionXStart <= mouseX && mouseX < rightCollisionXEnd)) && collisionYStart <= mouseY && mouseY < collisionYEnd) {
                        selectedEditingItem.add(nowStage.getJSONObject("player"));
                        println("add player");
                        selectedEditingItem.get(0).setString("type", "player");
                        setColPos();
                        return;
                    }
                    collisionXStart = nowStage.getJSONObject("goal").getFloat("x")-blockSize;
                    collisionYStart = totalHeight - nowStage.getJSONObject("goal").getFloat("y") - baseY - blockSize;
                    collisionXEnd = collisionXStart + ballSize;
                    collisionYEnd = collisionYStart + ballSize;
                    leftCollisionXStart = collisionXStart - width;
                    leftCollisionXEnd = collisionXEnd - width;
                    rightCollisionXStart = collisionXStart + width;
                    rightCollisionXEnd = collisionXEnd + width;
                    if (((collisionXStart <= mouseX && mouseX < collisionXEnd) || (leftCollisionXStart <= mouseX && mouseX < leftCollisionXEnd) || (rightCollisionXStart <= mouseX && mouseX < rightCollisionXEnd)) && collisionYStart <= mouseY && mouseY < collisionYEnd) {
                        selectedEditingItem.add(nowStage.getJSONObject("goal"));
                        println("add goal");
                        selectedEditingItem.get(0).setString("type", "goal");
                        setColPos();
                        return;
                    }
                    JSONArray boostItemsJSON = nowStage.getJSONArray("boostItems");
                    for (int i = boostItemsJSON.size()-1; i >= 0; i--) {
                        collisionXStart = boostItemsJSON.getJSONObject(i).getFloat("x")-blockSize;
                        collisionYStart = totalHeight - boostItemsJSON.getJSONObject(i).getFloat("y") - baseY - blockSize;
                        collisionXEnd = collisionXStart + ballSize;
                        collisionYEnd = collisionYStart + ballSize;
                        leftCollisionXStart = collisionXStart - width;
                        leftCollisionXEnd = collisionXEnd - width;
                        rightCollisionXStart = collisionXStart + width;
                        rightCollisionXEnd = collisionXEnd + width;
                        if (((collisionXStart <= mouseX && mouseX < collisionXEnd) || (leftCollisionXStart <= mouseX && mouseX < leftCollisionXEnd) || (rightCollisionXStart <= mouseX && mouseX < rightCollisionXEnd)) && collisionYStart <= mouseY && mouseY < collisionYEnd) {
                            selectedEditingItem.add(boostItemsJSON.getJSONObject(i));
                            println("add boostItem");
                            selectedEditingItem.get(0).setString("type", "boostItem");
                            boostItemsJSON.remove(i);
                            nowStage.setJSONArray("boostItems", boostItemsJSON);
                            setColPos();
                            return;
                        }
                    }
                    collisionXStart = 0;
                    collisionYStart = totalHeight - nowStage.getJSONObject("acid").getFloat("y") - baseY;
                    collisionXEnd = width;
                    collisionYEnd = collisionYStart + blockSize;
                    leftCollisionXStart = collisionXStart - width;
                    leftCollisionXEnd = collisionXEnd - width;
                    rightCollisionXStart = collisionXStart + width;
                    rightCollisionXEnd = collisionXEnd + width;
                    if (((collisionXStart <= mouseX && mouseX < collisionXEnd) || (leftCollisionXStart <= mouseX && mouseX < leftCollisionXEnd) || (rightCollisionXStart <= mouseX && mouseX < rightCollisionXEnd)) && collisionYStart <= mouseY && mouseY < collisionYEnd) {
                        selectedEditingItem.add(nowStage.getJSONObject("acid"));
                        println("add acid");
                        selectedEditingItem.get(0).setString("type", "acid");
                        setColPos();
                        return;
                    }
                    JSONArray platformsJSON = nowStage.getJSONArray("platforms");
                    for (int i = platformsJSON.size()-1; i >= 0; i--) {
                        collisionXStart = platformsJSON.getJSONObject(i).getFloat("x");
                        collisionYStart = totalHeight - platformsJSON.getJSONObject(i).getFloat("y") - baseY;
                        collisionXEnd = collisionXStart + blockSize*platformsJSON.getJSONObject(i).getInt("w");
                        collisionYEnd = collisionYStart + blockSize;
                        leftCollisionXStart = collisionXStart - width;
                        leftCollisionXEnd = collisionXEnd - width;
                        rightCollisionXStart = collisionXStart + width;
                        rightCollisionXEnd = collisionXEnd + width;
                        if (((collisionXStart <= mouseX && mouseX < collisionXEnd) || (leftCollisionXStart <= mouseX && mouseX < leftCollisionXEnd) || (rightCollisionXStart <= mouseX && mouseX < rightCollisionXEnd)) && collisionYStart <= mouseY && mouseY < collisionYEnd) {
                            selectedEditingItem.add(platformsJSON.getJSONObject(i));
                            println("add platform");
                            selectedEditingItem.get(0).setString("type", "platform");
                            platformsJSON.remove(i);
                            nowStage.setJSONArray("platforms", platformsJSON);
                            setColPos();
                            return;
                        }
                    }
                    JSONArray movePlatformsJSON = nowStage.getJSONArray("movePlatforms");
                    for (int i = movePlatformsJSON.size()-1; i >= 0; i--) {
                        collisionXStart = movePlatformsJSON.getJSONObject(i).getFloat("x");
                        collisionYStart = totalHeight - movePlatformsJSON.getJSONObject(i).getFloat("y") - baseY;
                        collisionXEnd = collisionXStart + blockSize*movePlatformsJSON.getJSONObject(i).getInt("w");
                        collisionYEnd = collisionYStart + blockSize;
                        leftCollisionXStart = collisionXStart - width;
                        leftCollisionXEnd = collisionXEnd - width;
                        rightCollisionXStart = collisionXStart + width;
                        rightCollisionXEnd = collisionXEnd + width;
                        if (((collisionXStart <= mouseX && mouseX < collisionXEnd) || (leftCollisionXStart <= mouseX && mouseX < leftCollisionXEnd) || (rightCollisionXStart <= mouseX && mouseX < rightCollisionXEnd)) && collisionYStart <= mouseY && mouseY < collisionYEnd) {
                            selectedEditingItem.add(movePlatformsJSON.getJSONObject(i));
                            println("add movePlatform");
                            selectedEditingItem.get(0).setString("type", "movePlatform");
                            movePlatformsJSON.remove(i);
                            nowStage.setJSONArray("movePlatforms", movePlatformsJSON);
                            setColPos();
                            return;
                        }
                    }
                }
                if (rightMousePressed) {
                    if (selectedEditingItem.size() == 0 && keyCoolCount < 0) {
                        keyCoolCount = keyCoolFrame;
                        if (addType.equals("platform")) {
                            JSONObject newAddItem = JSONObject.parse(templateItems.getJSONObject("platform").toString());
                            newAddItem.setFloat("x", mouseX);
                            newAddItem.setFloat("y", totalHeight - mouseY - baseY);
                            collisionXStart = newAddItem.getFloat("x");
                            collisionYStart = totalHeight - newAddItem.getFloat("y") - baseY;
                            collisionXEnd = collisionXStart + blockSize*newAddItem.getInt("w");
                            collisionYEnd = collisionYStart + blockSize;
                            selectedEditingItem.add(newAddItem);
                            println("add platform");
                            selectedEditingItem.get(0).setString("type", "platform");
                            setColPos();
                            return;
                        } else if (addType.equals("movePlatform")) {
                            JSONObject newAddItem = JSONObject.parse(templateItems.getJSONObject("movePlatform").toString());
                            newAddItem.setFloat("x", mouseX);
                            newAddItem.setFloat("y", totalHeight - mouseY - baseY);
                            collisionXStart = newAddItem.getFloat("x");
                            collisionYStart = totalHeight - newAddItem.getFloat("y") - baseY;
                            collisionXEnd = collisionXStart + blockSize*newAddItem.getInt("w");
                            collisionYEnd = collisionYStart + blockSize;
                            selectedEditingItem.add(newAddItem);
                            println("add movePlatform");
                            selectedEditingItem.get(0).setString("type", "movePlatform");
                            setColPos();
                            return;
                        } else if (addType.equals("boostItem")) {
                            JSONObject newAddItem = JSONObject.parse(templateItems.getJSONObject("boostItem").toString());
                            newAddItem.setFloat("x", mouseX);
                            newAddItem.setFloat("y", totalHeight - mouseY - baseY);
                            collisionXStart = newAddItem.getFloat("x")-blockSize;
                            collisionYStart = totalHeight - newAddItem.getFloat("y") - baseY - blockSize;
                            collisionXEnd = collisionXStart + ballSize;
                            collisionYEnd = collisionYStart + ballSize;
                            selectedEditingItem.add(newAddItem);
                            println("add boostItem");
                            selectedEditingItem.get(0).setString("type", "boostItem");
                            setColPos();
                            return;
                        }
                    }
                }
            } else {
                if (leftMousePressed || rightMousePressed) {    
                    collisionXStart = selectedEditingItem.get(0).getJSONObject("colPos").getFloat("collisionXStart");
                    collisionYStart = selectedEditingItem.get(0).getJSONObject("colPos").getFloat("collisionYStart");
                    collisionXEnd = selectedEditingItem.get(0).getJSONObject("colPos").getFloat("collisionXEnd");
                    collisionYEnd = selectedEditingItem.get(0).getJSONObject("colPos").getFloat("collisionYEnd");
                    leftCollisionXStart = selectedEditingItem.get(0).getJSONObject("colPos").getFloat("leftCollisionXStart");
                    leftCollisionXEnd = selectedEditingItem.get(0).getJSONObject("colPos").getFloat("leftCollisionXEnd");
                    rightCollisionXStart = selectedEditingItem.get(0).getJSONObject("colPos").getFloat("rightCollisionXStart");
                    rightCollisionXEnd = selectedEditingItem.get(0).getJSONObject("colPos").getFloat("rightCollisionXEnd");
                    if (((collisionXStart <= mousePX && mousePX < collisionXEnd) || (leftCollisionXStart <= mousePX && mousePX < leftCollisionXEnd) || (rightCollisionXStart <= mousePX && mousePX < rightCollisionXEnd)) && collisionYStart <= mousePY && mousePY < collisionYEnd) {
                        if (leftMousePressed) {
                            collisionXStart += mouseVX;
                            collisionYStart += mouseVY;
                            collisionXEnd += mouseVX;
                            collisionYEnd += mouseVY;
                            float meanCollisionX = (collisionXStart + collisionXEnd) / 2;
                            if (meanCollisionX < 0) {
                                collisionXStart += width;
                                collisionXEnd += width;
                                selectedEditingItem.get(0).setFloat("x", selectedEditingItem.get(0).getFloat("x")+mouseVX+width);
                            } else if (meanCollisionX >= width) {
                                collisionXStart -= width;
                                collisionXEnd -= width;
                                selectedEditingItem.get(0).setFloat("x", selectedEditingItem.get(0).getFloat("x")+mouseVX-width);
                            } else {
                                selectedEditingItem.get(0).setFloat("x", selectedEditingItem.get(0).getFloat("x")+mouseVX);
                            }
                            selectedEditingItem.get(0).setFloat("y", selectedEditingItem.get(0).getFloat("y")-mouseVY);

                            setColPos();

                            if (selectedEditingItem.get(0).getString("type").equals("acid")) {
                                acidY = str(selectedEditingItem.get(0).getFloat("y"));
                            }
                        } else if(keyCoolCount < 0){
                            reloadItemInfo(selectedEditingItem.get(0));
                            pastScene = scene;
                            scene = ITEMINFO;
                        }
                        return;
                    }
                    reloadEditingStage();
                }
            }
        } else if(scene == EDITGAME) {
            gameCollision();
        } else if (scene == EDITINFO) {
            // 
        } else if (scene == ITEMINFO) {
            // 
        }
    }

    void display() {
        if (scene == EDIT || scene == ITEMINFO) {
            stroke(0, 63);
            for (int y = 0; y < totalHeight; y+=blockSize) {
                float drawY = y - baseY;
                if (-blockSize <= drawY && drawY < height+blockSize) {
                    line(0, drawY, width, drawY);
                }
            }
            for (int x = 0; x < width; x+=blockSize) {
                line(x, 0, x, height);
            }
            noStroke();

            JSONObject displayStage = JSONObject.parse(nowStage.toString());
            if (selectedEditingItem.size() > 0) {
                JSONObject selectedItem = JSONObject.parse(selectedEditingItem.get(0).toString());
                String type = selectedItem.getString("type");
                if (type.equals("player")) {
                    displayStage.setJSONObject("player", selectedItem);
                } else if (type.equals("goal")) {
                    displayStage.setJSONObject("goal", selectedItem);
                } else if (type.equals("boostItem")) {
                    displayStage.getJSONArray("boostItems").append(selectedItem);
                } else if (type.equals("acid")) {
                    displayStage.setJSONObject("acid", selectedItem);
                } else if (type.equals("platform")) {
                    displayStage.getJSONArray("platforms").append(selectedItem);
                } else if (type.equals("movePlatform")) {
                    displayStage.getJSONArray("movePlatforms").append(selectedItem);
                }
                noFill();
                stroke(255, 0, 0);
                rect(collisionXStart - 1, collisionYStart - 1, collisionXEnd - collisionXStart + 2, collisionYEnd - collisionYStart + 2);
                stroke(0, 255, 0);
                rect(leftCollisionXStart - 1, collisionYStart - 1, leftCollisionXEnd - leftCollisionXStart + 2, collisionYEnd - collisionYStart + 2);
                stroke(255, 255, 0);
                rect(rightCollisionXStart - 1, collisionYStart - 1, rightCollisionXEnd - rightCollisionXStart + 2, collisionYEnd - collisionYStart + 2);
                noStroke();

                fill(255);
                textSize(20);
                textAlign(LEFT, CENTER);
                text(type, 0, 30);
                text(selectedItem.getFloat("x"), 0, 50);
                text(selectedItem.getFloat("y"), 80, 50);
            }
            stages.clear();
            stages.add(displayStage);
            loadStage(0);
            gameDisplay();

            fill(255);
            textSize(20);
            textAlign(LEFT, CENTER);
            text(addType, 30, 10);
            stroke(255, 255, 0);
            fill(0, 0, 0, 191);
            rect(100-4, 20-4, blockSize+8, blockSize+8);
            noStroke();
            if (addType.equals("platform")) {
                image(images.get("block"), 100, 20, blockSize, blockSize);
            } else if (addType.equals("movePlatform")) {
                image(images.get("jerry"), 100, 20, blockSize, blockSize);
            } else if (addType.equals("boostItem")) {
                image(images.get("fish"), 100, 20, blockSize, blockSize);
            }
        } else if(scene == EDITGAME || scene == EDITDEAD) {
            gameDisplay();
        } else if(scene == EDITINFO) {
            textSize(20);
            textAlign(CENTER, CENTER);

            fill(255, 0, 0);
            text("acid", width/2, height*7/10);
            fill(255);
            text("JsonName", width*2/5, height*3/10);
            text("StageName", width*2/5, height*3.5/10);
            text("Difficulty", width*2/5, height*4/10);
            text("Author", width*2/5, height*4.5/10);
            text("BGColor", width*2/5, height*5/10);
            text("Height", width*2/5, height*5.5/10);
            text("AcidY", width*2/5, height*8/10);
            text("AcidVY", width*2/5, height*8.5/10);
            text(newJsonName, width*3/5, height*3/10);
            text(newStageName, width*3/5, height*3.5/10);
            text(newStageDifficulty, width*3/5, height*4/10);
            text(newStageAuthor, width*3/5, height*4.5/10);
            text(newBGColor, width*3/5, height*5/10);
            text(newHeight, width*3/5, height*5.5/10);
            text(acidY, width*3/5, height*8/10);
            text(acidVY, width*3/5, height*8.5/10);

            stroke(255, 255, 0);
            if (stageInfoNum < 6) {
                line(width/3, height*(stageInfoNum+6)*0.5/10 + 10, width*2/3, height*(stageInfoNum+6)*0.5/10 + 10);
            } else {
                line(width/3, height*(stageInfoNum+10)*0.5/10 + 10, width*2/3, height*(stageInfoNum+10)*0.5/10 + 10);
            }
            noStroke();
        }

        fill(0);
        textSize(10);
        textAlign(LEFT, CENTER);
        line(0, 0, 0, height);
        stroke(0);
        for (int y = 0; y < totalHeight+blockSize; y+=ballSize) {
            float drawY = y - baseY;
            if (-blockSize <= drawY && drawY < height+blockSize) {
                fill(255);
                line(0, drawY, blockSize, drawY);
                text(totalHeight-y, blockSize, drawY);
            }
        }
        noStroke();

        if (scene == ITEMINFO) {
            fill(0, 127);
            rect(0, 0, width, height);
            fill(0);
            rect(width/4, height/4, width/2, height/2);
            fill(255, 0, 0);
            textSize(40);
            textAlign(CENTER, CENTER);
            text("INFO", width/2, height/4+30);
            textSize(20);
            fill(255);
            textAlign(LEFT, UP);
            // JSONObject selectedItem = JSONObject.parse(selectedEditingItem.get(0).toString());
            // text(selectedItem.toString(), width/4+50, height/4+50);
            
            for (int i = 0; i < itemInfoStrings.size(); i++) {
                String key = itemInfoStrings.get(i).get(0);
                String value;
                text(key + " : ", width/4+50, height/4+100+30*i);
                if (key.equals("w") || key.equals("jumpCount")) {
                    value = itemInfoStrings.get(i).get(1);
                    text(value, width/4+200, height/4+100+30*i);
                } else {
                    value = itemInfoStrings.get(i).get(1);
                    text(value, width/4+200, height/4+100+30*i);
                }
            }
            stroke(255, 255, 0);
            line(width/4+40, height/4+110+30*itemInfoNum, width*3/4-40, height/4+110+30*itemInfoNum);
            noStroke();
        }

        textSize(20);
        fill(255);
        text(selectedEditingItem.size(), 10, 10);
    }

    void reloadEditingStage() {
        if (selectedEditingItem.size() > 0) {
            JSONObject selectedItem = JSONObject.parse(selectedEditingItem.get(0).toString());
            String type = selectedItem.getString("type");
            selectedItem.remove("type");
            selectedItem.remove("colPos");
            if (type.equals("player")) {
                nowStage.setJSONObject("player", selectedItem);
            } else if (type.equals("goal")) {
                nowStage.setJSONObject("goal", selectedItem);
            } else if (type.equals("boostItem")) {
                nowStage.getJSONArray("boostItems").append(selectedItem);
            } else if (type.equals("acid")) {
                nowStage.setJSONObject("acid", selectedItem);
            } else if (type.equals("platform")) {
                nowStage.getJSONArray("platforms").append(selectedItem);
            } else if (type.equals("movePlatform")) {
                nowStage.getJSONArray("movePlatforms").append(selectedItem);
            }
        }
        fixStageInfo();
        nowStage.setInt("difficulty", newStageDifficulty);
        nowStage.setString("author", newStageAuthor);
        nowStage.setString("bgColor", "#" + newBGColor);
        nowStage.setInt("height", newHeight);
        nowStage.getJSONObject("acid").setFloat("y", float(acidY));
        nowStage.getJSONObject("acid").setFloat("vy", float(acidVY));

        stages.clear();
        stages.add(nowStage);
        selectedEditingItem.clear();
        loadStage(0);
    }

    void clesrSelectedEditingItem() {
        if (selectedEditingItem.size() > 0) {
            String type = selectedEditingItem.get(0).getString("type");
            selectedEditingItem.clear();
            println("remove " + type);
        }
    }

    void saveEditStage() {
        JSONObject saveStage = JSONObject.parse(nowStage.toString());
        if (selectedEditingItem.size() > 0) {
            JSONObject selectedItem = JSONObject.parse(selectedEditingItem.get(0).toString());
            String type = selectedItem.getString("type");
            selectedItem.remove("type");
            selectedItem.remove("colPos");
            if (type.equals("player")) {
                saveStage.setJSONObject("player", selectedItem);
            } else if (type.equals("goal")) {
                saveStage.setJSONObject("goal", selectedItem);
            } else if (type.equals("boostItem")) {
                saveStage.getJSONArray("boostItems").append(selectedItem);
            } else if (type.equals("acid")) {
                saveStage.setJSONObject("acid", selectedItem);
            } else if (type.equals("platform")) {
                saveStage.getJSONArray("platforms").append(selectedItem);
            } else if (type.equals("movePlatform")) {
                saveStage.getJSONArray("movePlatforms").append(selectedItem);
            }
        }
        fixStageInfo();
        saveStage.setInt("difficulty", newStageDifficulty);
        saveStage.setString("author", newStageAuthor);
        saveStage.setString("bgColor", "#" + newBGColor);
        saveStage.setInt("height", newHeight);
        saveStage.getJSONObject("acid").setFloat("y", float(acidY));
        saveStage.getJSONObject("acid").setFloat("vy", float(acidVY));

        JSONObject fromJson = stagess.getJSONObject(selectedJsonName);
        JSONObject toJson = stagess.getJSONObject(newJsonName);
        if (fromJson == null) {
            fromJson = new JSONObject();
        }
        if (toJson == null) {
            toJson = new JSONObject();
        }
        fromJson.remove(selectedStageName);
        toJson.setJSONObject(newStageName, saveStage);
        String saveFromPath = folderPath + "/" + selectedJsonName + ".json";
        saveJSONObject(fromJson, saveFromPath);
        String saveToPath = folderPath + "/" + newJsonName + ".json";
        saveJSONObject(toJson, saveToPath);
        println("save " + newJsonName + " " + newStageName);
    }
}


void loadStage(int num) {
    JSONObject stage = stages.get(num);

    JSONObject playerJSON = stage.getJSONObject("player");
    JSONArray platformsJSON = stage.getJSONArray("platforms");
    JSONArray movePlatformsJSON = stage.getJSONArray("movePlatforms");
    JSONArray boostItemsJSON = stage.getJSONArray("boostItems");

    if (!(scene == EDIT || scene == EDITGAME || scene == EDITDEAD || scene == EDITINFO || scene == ITEMINFO)) {
        stars.clear();
    }
    platforms.clear();
    movePlatforms.clear();
    boostItems.clear();

    nowStageName = stage.getString("stageName");
    nowAuthor = stage.getString("author");
    nowDifficulty = stage.getInt("difficulty");

    String bgColorHex = stage.getString("bgColor").replace("#", "");
    gameBGColor = unhex(bgColorHex);
    totalHeight = stage.getInt("height");
    if (totalHeight < height) {
        totalHeight = height;
    }
    if (!(scene == EDIT || scene == EDITGAME || scene == EDITDEAD || scene == EDITINFO || scene == ITEMINFO) || firstEditLoad) {
        baseY = totalHeight - height;
        firstEditLoad = false;
    }
    if (baseY < 0) {
        baseY = 0;
    } else if (baseY > totalHeight - height) {
        baseY = totalHeight - height;
    }
    
    player = new Player(playerJSON.getFloat("x"), totalHeight - playerJSON.getFloat("y"));
    player.maxVelocity = playerJSON.getFloat("v");
    player.gravity = playerJSON.getFloat("g");
    player.maxJump = playerJSON.getFloat("jump");
    baseJumpCount = playerJSON.getInt("jumpCount");
    player.jumpCount = baseJumpCount;
    player.fullChargeFrame = (int)(fps * playerJSON.getFloat("chargeTime"));

    goal = new GoalItem(stage.getJSONObject("goal").getFloat("x"), totalHeight - stage.getJSONObject("goal").getFloat("y"));
    // platforms.add(new Platform(0, totalHeight - blockSize*6, width/blockSize));
    acid = new Acid(totalHeight - stage.getJSONObject("acid").getFloat("y"), stage.getJSONObject("acid").getFloat("vy"));
    if (!(scene == EDIT || scene == EDITGAME || scene == EDITDEAD || scene == EDITINFO || scene == ITEMINFO)) {
        for (int i = 0; i < stage.getInt("starNum"); i++) {
            stars.add(new Star());
        }
    }
    for (int i = 0; i < platformsJSON.size(); i++) {
        JSONObject platformJSON = platformsJSON.getJSONObject(i);
        platforms.add(new Platform(platformJSON.getFloat("x"), totalHeight - platformJSON.getFloat("y"), platformJSON.getInt("w")));
    }
    for (int i = 0; i < movePlatformsJSON.size(); i++) {
        JSONObject movePlatformJSON = movePlatformsJSON.getJSONObject(i);
        movePlatforms.add(new MovePlatform(movePlatformJSON.getFloat("x"), totalHeight - movePlatformJSON.getFloat("y"), movePlatformJSON.getInt("w"), movePlatformJSON.getFloat("vx"), movePlatformJSON.getFloat("rangeX")));
    }
    for (int i = 0; i < boostItemsJSON.size(); i++) {
        JSONObject boostItemJSON = boostItemsJSON.getJSONObject(i);
        boostItems.add(new BoostItem(boostItemJSON.getFloat("x"), totalHeight - boostItemJSON.getFloat("y")));
    }
}

void gameCollision() {
    player.update();
    goal.collision(player);
    for (BoostItem boostItem : boostItems) {
        boostItem.collision(player);
    }
    for (Platform platform : platforms) {
        platform.collision(player);
    }
    for (MovePlatform movePlatform : movePlatforms) {
        movePlatform.update();
        movePlatform.collision(player);
    }
    acid.update();
    acid.collision(player);
}

void gameDisplay() {
    for (Star star : stars) {
        for (int i = 0; i < totalHeight; i += height) {
            star.display(i);
        }
    }
    goal.display();
    for (BoostItem boostItem : boostItems) {
        boostItem.display();
    }
    for (Platform platform : platforms) {
        platform.display();
    }
    for (MovePlatform movePlatform : movePlatforms) {
        movePlatform.display();
    }
    acid.display();
    player.display();
}


String nowStageName = "";
String nowAuthor = "";
int nowDifficulty = 0;
Player player;
GoalItem goal;
Acid acid;
ArrayList<Star> stars = new ArrayList<Star>();
ArrayList<BoostItem> boostItems = new ArrayList<BoostItem>();
ArrayList<Platform> platforms = new ArrayList<Platform>();
ArrayList<MovePlatform> movePlatforms = new ArrayList<MovePlatform>();

EditingStage editingStage;

void setup() {
    size(800, 700);
    frameRate(fps);
    background(bgColor);
    noStroke();

    folderPath = sketchPath("STAGESs");
    templateStage = loadJSONObject("template.json").getJSONObject("template");
    templateStage.setString("stageName", "template");
    templateItems = loadJSONObject("templateItems.json");
    // stages = loadJSONArray("stages.json");
    sounds.put("jump", new SoundFile(this, "sounds/jump.mp3"));
    sounds.put("clear", new SoundFile(this, "sounds/clear.mp3"));
    sounds.put("fish", new SoundFile(this, "sounds/fish.mp3"));
    sounds.put("dead", new SoundFile(this, "sounds/dead.mp3"));
    sounds.put("gameover", new SoundFile(this, "sounds/gameover.mp3"));
    images.put("ika", loadImage("images/ika.png"));
    images.put("charge1", loadImage("images/charge1.png"));
    images.put("charge2", loadImage("images/charge2.png"));
    images.put("charge3", loadImage("images/charge3.png"));
    images.put("charge4", loadImage("images/charge4.png"));
    images.put("charge5", loadImage("images/charge5.png"));
    images.put("charge6", loadImage("images/charge6.png"));
    images.put("dead", loadImage("images/dead.png"));
    images.put("goal", loadImage("images/goal.png"));
    images.put("block", loadImage("images/block.png"));
    images.put("jerry", loadImage("images/jerry.png"));
    images.put("acid", loadImage("images/acid.png"));
    images.put("fish", loadImage("images/fish.png"));
    
    mainMenuStrings.add(parseJSONObject("{\"name\": \"PLAY\",\"x\": 200,\"y\": 350,\"UP\": 0,\"LEFT\": 0,\"DOWN\": 3,\"RIGHT\": 1}"));
    mainMenuStrings.add(parseJSONObject("{\"name\": \"CONTINUE\",\"x\": 400,\"y\": 350,\"UP\": 1,\"LEFT\": 0,\"DOWN\": 3,\"RIGHT\": 2}"));
    mainMenuStrings.add(parseJSONObject("{\"name\": \"SELECT\",\"x\": 600,\"y\": 350,\"UP\": 2,\"LEFT\": 1,\"DOWN\": 4,\"RIGHT\": 2}"));
    mainMenuStrings.add(parseJSONObject("{\"name\": \"NEW\",\"x\": 300,\"y\": 500,\"UP\": 0,\"LEFT\": 3,\"DOWN\": 3,\"RIGHT\": 4}"));
    mainMenuStrings.add(parseJSONObject("{\"name\": \"SELECT\",\"x\": 500,\"y\": 500,\"UP\": 2,\"LEFT\": 3,\"DOWN\": 4,\"RIGHT\": 4}"));

    stageMenuStrings.add("Play");
    stageMenuStrings.add("Edit");
    stageMenuStrings.add("Move");
    stageMenuStrings.add("Copy");
    stageMenuStrings.add("Delete");

    jsonMenuStrings.add("Play");
    jsonMenuStrings.add("EditName");
    jsonMenuStrings.add("Copy");
    
    editingStage = new EditingStage(templateStage);

    loadJSONs();
    stages = new ArrayList<JSONObject>(allStages);
    maxStageNum = stages.size() - 1;
    loadStage(stageNum);
}



boolean wasSpaceKeyPressed = false;
void draw() {
    mouseVX = mouseX - mousePX;
    mouseVY = mouseY - mousePY;

    if (scene == GAME || scene == GOAL || scene == DEAD || scene == PAUSE || scene == EDIT || scene == EDITGAME || scene == EDITDEAD || scene == EDITINFO || scene == ITEMINFO) {
        background(gameBGColor);
    } else {
        background(bgColor);
    }

    if (scene == GOAL || scene == DEAD || scene == EDITDEAD) {
        if (waitFrame > fps*3/2) {
            if (scene == GOAL) {
                loadStage(stageNum);
                pastScene = scene;
                scene = GAME;
            } else if (scene == DEAD) {
                loadStage(stageNum);
                pastScene = scene;
                scene = GAME;
            } else if (scene == EDITDEAD) {
                loadStage(0);
                pastScene = scene;
                scene = EDIT;
            }
            waitFrame = 0;
        } else {
            waitFrame++;
        }
    }

    if (scene == MAIN) {
        JSONObject mainMenuString = mainMenuStrings.get(selectedMainNum);
        if (keyCoolCount < 0 && (keys['W'] || keys['w'] || keys[UP])) {
            keyCoolCount = keyCoolFrame;
            selectedMainNum = mainMenuString.getInt("UP");
        }
        if (keyCoolCount < 0 && (keys['A'] || keys['a'] || keys[LEFT])) {
            keyCoolCount = keyCoolFrame;
            selectedMainNum = mainMenuString.getInt("LEFT");
        }
        if (keyCoolCount < 0 && (keys['S'] || keys['s'] || keys[DOWN])) {
            keyCoolCount = keyCoolFrame;
            selectedMainNum = mainMenuString.getInt("DOWN");
        }
        if (keyCoolCount < 0 && (keys['D'] || keys['d'] || keys[RIGHT])) {
            keyCoolCount = keyCoolFrame;
            selectedMainNum = mainMenuString.getInt("RIGHT");
        }
        if (keyCoolCount < 0 && (keys[ENTER] || keys[RETURN] || keys[' '] || keys[32])) {
            keyCoolCount = keyCoolFrame;
            if (selectedMainNum == 0) {
                println("Play");
                pastScene = scene;
                scene = GAME;
                stages = new ArrayList<JSONObject>(allStages);
                maxStageNum = stages.size() - 1;
                stageNum = 0;
                loadStage(stageNum);
            } else if (selectedMainNum == 1) {
                println("Continue");
                pastScene = scene;
                scene = GAME;
                stages = new ArrayList<JSONObject>(allStages);
                maxStageNum = stages.size() - 1;
                stageNum = allStageNum;
                loadStage(stageNum);
            } else if (selectedMainNum == 2) {
                println("Select");
                loadJSONs();
                pastScene = scene;
                scene = MENU;
                isFocusStages = false;
                selectedJsonNum = 0;
            } else if (selectedMainNum == 3) {
                println("New");
                selectedJsonName = "newJson";
                selectedStageName = "newStage";
                editingStage = new EditingStage(templateStage);
                pastScene = scene;
                scene = EDIT;
            } else if (selectedMainNum == 4) {
                println("Select");
                loadJSONs();
                pastScene = scene;
                scene = MENU;
                isFocusStages = false;
                selectedJsonNum = 0;
            }
        }
        
    }
    if (scene == MENU) {
        if (keyCoolCount < 0 && (keys['W'] || keys['w'] || keys[UP])) {
            keyCoolCount = keyCoolFrame;
            if (isFocusStages) {
                selectedStageNum--;
                if (selectedStageNum < 0) {
                    selectedStageNum = stageNames.size() - 1;
                } else if (selectedStageNum >= stageNames.size()) {
                    selectedStageNum = 0;
                }
            } else {
                selectedJsonNum--;
                if (selectedJsonNum < 0) {
                    selectedJsonNum = jsonNames.size() - 1;
                } else if (selectedJsonNum >= jsonNames.size()) {
                    selectedJsonNum = 0;
                }
            }
            adjustMenuBaseY();
        }
        if (keyCoolCount < 0 && (keys['A'] || keys['a'] || keys[LEFT])) {
            keyCoolCount = keyCoolFrame;
            isFocusStages = false;
            selectedStageNum = 0;
            adjustMenuBaseY();
        }
        if (keyCoolCount < 0 && (keys['S'] || keys['s'] || keys[DOWN])) {
            keyCoolCount = keyCoolFrame;
            if (isFocusStages) {
                selectedStageNum++;
                if (selectedStageNum < 0) {
                    selectedStageNum = stageNames.size() - 1;
                } else if (selectedStageNum >= stageNames.size()) {
                    selectedStageNum = 0;
                }
            } else {
                selectedJsonNum++;
                if (selectedJsonNum < 0) {
                    selectedJsonNum = jsonNames.size() - 1;
                } else if (selectedJsonNum >= jsonNames.size()) {
                    selectedJsonNum = 0;
                }
            }
            adjustMenuBaseY();
        }
        if (keyCoolCount < 0 && (keys['D'] || keys['d'] || keys[RIGHT])) {
            keyCoolCount = keyCoolFrame;
            isFocusStages = true;
            adjustMenuBaseY();
        }

        stageNames = new ArrayList<String>(stagess.getJSONObject(jsonNames.get(selectedJsonNum)).keys());

        if (keyCoolCount < 0 && (keys[ENTER] || keys[RETURN] || keys[' '] || keys[32])) {
            keyCoolCount = keyCoolFrame;
            // loadJSONs();
            if (isFocusStages) {
                selectedJsonName = jsonNames.get(selectedJsonNum);
                selectedStageName = stageNames.get(selectedStageNum);
                JSONObject stage = stagess.getJSONObject(selectedJsonName).getJSONObject(selectedStageName);
                // println(stage);

                selectedJsonMenuNum = 0;
                selectedStageMenuNum = 0;
                pastScene = scene;
                scene = STAGEMENU;
            } else {
                selectedJsonName = jsonNames.get(selectedJsonNum);
                println(selectedJsonName);
                selectedJsonMenuNum = 0;
                selectedStageMenuNum = 0;
                pastScene = scene;
                scene = STAGEMENU;
            }
        }
        if (keyCoolCount < 0 && keys[ESC]) {
            keyCoolCount = keyCoolFrame;
            pastScene = scene;
            scene = MAIN;
        }
    }


    if (scene == STAGEMENU) {
        if (keyCoolCount < 0 && (keys['W'] || keys['w'] || keys[UP])) {
            keyCoolCount = keyCoolFrame;
            if (isFocusStages) {
                selectedStageMenuNum--;
                if (selectedStageMenuNum < 0) {
                    selectedStageMenuNum = stageMenuStrings.size() - 1;
                } else if (selectedStageMenuNum >= stageMenuStrings.size()) {
                    selectedStageMenuNum = 0;
                }
            } else {
                selectedJsonMenuNum--;
                if (selectedJsonMenuNum < 0) {
                    selectedJsonMenuNum = jsonMenuStrings.size() - 1;
                } else if (selectedJsonMenuNum >= jsonMenuStrings.size()) {
                    selectedJsonMenuNum = 0;
                }
            }
        }
        if (keyCoolCount < 0 && (keys['S'] || keys['s'] || keys[DOWN])) {
            keyCoolCount = keyCoolFrame;
            if (isFocusStages) {
                selectedStageMenuNum++;
                if (selectedStageMenuNum < 0) {
                    selectedStageMenuNum = stageMenuStrings.size() - 1;
                } else if (selectedStageMenuNum >= stageMenuStrings.size()) {
                    selectedStageMenuNum = 0;
                }
            } else {
                selectedJsonMenuNum++;
                if (selectedJsonMenuNum < 0) {
                    selectedJsonMenuNum = jsonMenuStrings.size() - 1;
                } else if (selectedJsonMenuNum >= jsonMenuStrings.size()) {
                    selectedJsonMenuNum = 0;
                }
            }
        }

        // STAGEMENUで編集した場合、loadで更新をする！！！

        if (keyCoolCount < 0 && (keys[ENTER] || keys[RETURN] || keys[' '] || keys[32])) {
            keyCoolCount = keyCoolFrame;
            // loadJSONs();
            if (isFocusStages) {
                if (selectedStageMenuNum == 0) {
                    println("Play");
                    pastScene = scene;
                    scene = GAME;
                    stages.clear();
                    stages.add(stagess.getJSONObject(selectedJsonName).getJSONObject(selectedStageName));
                    maxStageNum = stages.size() - 1;
                    loadStage(0);
                } else if (selectedStageMenuNum == 1) {
                    println("Edit");
                    editingStage = new EditingStage(stagess.getJSONObject(selectedJsonName).getJSONObject(selectedStageName));
                    pastScene = scene;
                    scene = EDIT;
                } else if (selectedStageMenuNum == 2) {
                    println("Move");
                } else if (selectedStageMenuNum == 3) {
                    println("Copy");
                } else if (selectedStageMenuNum == 4) {
                    println("Delete");
                }
            } else {
                if (selectedJsonMenuNum == 0) {
                    println("Play");
                    // loadStage(stageNum);
                    pastScene = scene;
                    scene = GAME;
                    stages.clear();
                    JSONObject jsonObject = stagess.getJSONObject(selectedJsonName);
                    Set<String> keys = jsonObject.keys();
                    for (String key : keys) {
                        stages.add(jsonObject.getJSONObject(key));
                    }
                    maxStageNum = stages.size() - 1;
                    stageNum = 0;
                    loadStage(stageNum);
                } else if (selectedJsonMenuNum == 1) {
                    println("EditName");
                } else if (selectedJsonMenuNum == 2) {
                    println("Copy");
                }
            }
        }
        if (keyCoolCount < 0 && (keys[ESC])) {
            keyCoolCount = keyCoolFrame;
            // loadJSONs();
            pastScene = scene;
            scene = MENU;
        }
    }

    if (scene == GAME || scene == EDITGAME) {
        player.move(0);
        if (keys['A'] || keys['a'] || keys[LEFT]) {
            player.move(-1);
        }
        if (keys['D'] || keys['d'] || keys[RIGHT]) {
            player.move(1);
        }
        if (keys[' '] || keys[32]) {
            wasSpaceKeyPressed = true;
            player.chargeJump();
        } else if (wasSpaceKeyPressed) {
            player.jump();
            wasSpaceKeyPressed = false;
        }
        if (keys['R'] || keys['r']) {
            player.dead();
        }
        if (keyCoolCount < 0 && (keys[ESC] || keys['P'] || keys['p'])) {
            keyCoolCount = keyCoolFrame;
            if (scene == GAME) {
                pastScene = scene;
                scene = PAUSE;
            } else if (scene == EDITGAME) {
                pastScene = scene;
                scene = EDIT;
            }
        }
        if (scene == GAME) {
            gameCollision();
        }
    }
    if (scene == PAUSE) {
        if (keyCoolCount < 0 && (keys[' '] || keys[32] || keys['P'] || keys['p'])) {
            keyCoolCount = keyCoolFrame;
            pastScene = scene;
            scene = GAME;
        }
        if (keyCoolCount < 0 && keys[ESC]) {
            keyCoolCount = keyCoolFrame;
            // loadJSONs();
            if (selectedMainNum == 0 || selectedMainNum == 1) {
                pastScene = scene;
                scene = MAIN;
            } else if (selectedMainNum == 2 || selectedMainNum == 4) {
                pastScene = scene;
                scene = MENU;
                isFocusStages = false;
                selectedJsonNum = 0;
            }
        }
    }

    if (scene == EDIT) {
        if (keyCoolCount < 0 && keys[UP]) {
            keyCoolCount = keyCoolFrame/2;
            editingStage.editMove(0, -1);
        }
        if (keyCoolCount < 0 && keys[LEFT]) {
            keyCoolCount = keyCoolFrame/2;
            editingStage.editMove(-1, 0);
        }
        if (keyCoolCount < 0 && keys[DOWN]) {
            keyCoolCount = keyCoolFrame/2;
            editingStage.editMove(0, 1);
        }
        if (keyCoolCount < 0 && keys[RIGHT]) {
            keyCoolCount = keyCoolFrame/2;
            editingStage.editMove(1, 0);
        }
        if (keyCoolCount < 0 && (keys['W'] || keys['w'])) {
            keyCoolCount = keyCoolFrame/2;
            editingStage.editMove(0, -20);
        }
        if (keyCoolCount < 0 && (keys['A'] || keys['a'])) {
            keyCoolCount = keyCoolFrame/2;
            editingStage.editMove(-20, 0);
        }
        if (keyCoolCount < 0 && (keys['S'] || keys['s'])) {
            keyCoolCount = keyCoolFrame/2;
            editingStage.editMove(0, 20);
        }
        if (keyCoolCount < 0 && (keys['D'] || keys['d'])) {
            keyCoolCount = keyCoolFrame/2;
            editingStage.editMove(20, 0);
        }

        if (keyCoolCount < 0 && (keys['X'] || keys['x'])) {
            keyCoolCount = keyCoolFrame;
            editingStage.switchAddType();
        }
        if (keyCoolCount < 0 && (keys['Z'] || keys['z'])) {
            keyCoolCount = keyCoolFrame;
            editingStage.saveEditStage();
        }
        if (keyCoolCount < 0 && (keys[ENTER] || keys[RETURN])) {
            keyCoolCount = keyCoolFrame;
            if (editingStage.selectedEditingItem.size() > 0){
                editingStage.reloadItemInfo(editingStage.selectedEditingItem.get(0));
                pastScene = scene;
                scene = ITEMINFO;
            } else {
                keyCoolCount = keyCoolFrame;
                editingStage.reloadEditingStage();
                pastScene = scene;
                scene = EDITGAME;
            }
        }
        if (keyCoolCount < 0 && (keys[' '] || keys[32])) {
            keyCoolCount = keyCoolFrame;
            editingStage.reloadEditingStage();
            pastScene = scene;
            scene = EDITGAME;
        }
        if (keys[DELETE] || keys[BACKSPACE] || keys[127]) {
            editingStage.clesrSelectedEditingItem();
        }
        if (keyCoolCount < 0 && keys[ESC]) {
            keyCoolCount = keyCoolFrame;
            pastScene = scene;
            scene = EDITINFO;
        }
        editingStage.collision();
    }
    if (scene == EDITGAME) {
        editingStage.collision();
    }
    if (scene == EDITDEAD) {
        editingStage.collision();
    }
    if (scene == EDITINFO) {
        if (keyCoolCount < 0 && keys[UP]) {
            keyCoolCount = keyCoolFrame;
            editingStage.stageInfoNum--;
            if (editingStage.stageInfoNum < 0) {
                editingStage.stageInfoNum = 7;
            } else if (editingStage.stageInfoNum >= 8) {
                editingStage.stageInfoNum = 0;
            }
        }
        if (keyCoolCount < 0 && keys[DOWN]) {
            keyCoolCount = keyCoolFrame;
            editingStage.stageInfoNum++;
            if (editingStage.stageInfoNum < 0) {
                editingStage.stageInfoNum = 7;
            } else if (editingStage.stageInfoNum >= 8) {
                editingStage.stageInfoNum = 0;
            }
        }
        if (keyCoolCount < 0 && (keys[ENTER] || keys[RETURN])) {
            keyCoolCount = keyCoolFrame;
            editingStage.reloadEditingStage();
            pastScene = scene;
            scene = EDIT;
        }
        if (keyCoolCount < 0 && keys[RIGHT]) {
            keyCoolCount = keyCoolFrame;
            editingStage.fixStageInfo();
        }
        if (keyCoolCount < 0 && keys[ESC]) {
            keyCoolCount = keyCoolFrame;
            loadJSONs();
            pastScene = scene;
            if (selectedMainNum == 0 || selectedMainNum == 1 || selectedMainNum == 3) {
                scene = MAIN;
            } else if (selectedMainNum == 2 || selectedMainNum == 4) {
                scene = MENU;
                isFocusStages = false;
                selectedJsonNum = 0;
            }
            firstEditLoad = true;
        }
    }
    if (scene == ITEMINFO) {
        if (keyCoolCount < 0 && (keys['W'] || keys['w'] || keys[UP])) {
            keyCoolCount = keyCoolFrame;
            editingStage.itemInfoNum--;
            if (editingStage.itemInfoNum < 0) {
                editingStage.itemInfoNum = editingStage.itemInfoMax-1;
            } else if (editingStage.itemInfoNum >= editingStage.itemInfoMax) {
                editingStage.itemInfoNum = 0;
            }
        }
        if (keyCoolCount < 0 && (keys['S'] || keys['s'] || keys[DOWN])) {
            keyCoolCount = keyCoolFrame;
            editingStage.itemInfoNum++;
            if (editingStage.itemInfoNum < 0) {
                editingStage.itemInfoNum = editingStage.itemInfoMax-1;
            } else if (editingStage.itemInfoNum >= editingStage.itemInfoMax) {
                editingStage.itemInfoNum = 0;
            }
        }
        if (keyCoolCount < 0 && keys[RIGHT]) {
            keyCoolCount = keyCoolFrame;
            editingStage.saveItemInfo();            
        }
        if (keyCoolCount < 0 && (keys[ESC] || keys[ENTER] || keys[RETURN])) {
            keyCoolCount = keyCoolFrame;
            editingStage.saveItemInfo();  
            pastScene = scene;
            scene = EDIT;
        }
    }


    if (scene == GAME || scene == GOAL || scene == DEAD || scene == PAUSE) {
        gameDisplay();
    }
    if (scene == GOAL) {
        fill(255);
        textSize(50);
        textAlign(CENTER, CENTER);
        text("GOAL!", width/2, height/2);
    }
    if (scene == DEAD) {
        fill(255);
        textSize(50);
        textAlign(CENTER, CENTER);
        text("MISS!", width/2, height/2);
    }
    if (scene == PAUSE) {
        fill(0, 127);
        rect(0, 0, width, height);
        fill(255);
        textSize(20);
        textAlign(CENTER, CENTER);
        text("Press Space/P Key to Resume", width/2, height/2);
        text(nowStageName, width*0.1, height*0.1);
        text(nowAuthor, width*0.1, height*0.2);
        text(nowDifficulty, width*0.1, height*0.3);

    }
    if (scene == MAIN) {
        fill(255);
        textSize(50);
        textAlign(CENTER, CENTER);
        text("MAIN", width/2, height/10);
        for (int i = 0; i < mainMenuStrings.size(); i++) {
            if (i == selectedMainNum) {
                fill(255, 0, 0);
            } else {
                fill(255);
            }
            JSONObject mainMenuString = mainMenuStrings.get(i);
            text(mainMenuString.getString("name"), mainMenuString.getInt("x"), mainMenuString.getInt("y"));
        }
    }
    if (scene == MENU || scene == STAGEMENU) {
        fill(0, 31);
        rect(width/3, 0, width/3, height);
        textSize(30);
        textAlign(CENTER, CENTER);
        for (int i = 0; i < jsonNames.size(); i++) {
            String jsonName = jsonNames.get(i);
            if (i == selectedJsonNum) {
                if (isFocusStages) {
                    fill(255, 0, 255);
                } else {
                    fill(255, 0, 0);
                }
            } else {
                fill(255);
            }
            text(jsonName, width/5, height/4 + 50*(i+1) - jsonMenuBaseY);
        }
        for (int i = 0; i < stageNames.size(); i++) {
            String stageName = stageNames.get(i);
            if (i == selectedStageNum && isFocusStages) {
                fill(255, 0, 0);
            } else {
                fill(255);
            }
            text(stageName, width/2, height/4 + 50*(i+1) - stageMenuBaseY);
        }
        if (isFocusStages) {
            textAlign(LEFT, CENTER);
            JSONObject stage = stagess.getJSONObject(jsonNames.get(selectedJsonNum)).getJSONObject(stageNames.get(selectedStageNum));
            // println(stage);
            fill(255);
            text("Difficulty: " + stage.getInt("difficulty"), width*2/3 + 50, height/4 + 50);
            text("Author: " + stage.getString("author"), width*2/3 + 50, height/4 + 100);
        }
        textAlign(CENTER, CENTER);
        fill(bgColor);
        rect(0, 0, width, height/4+25);
        fill(255, 255, 0);
        text("JSON", width/5, height/4);
        text("STAGE", width/2, height/4);
        text("INFO", width*3/4, height/4);
        textSize(50);
        fill(255);
        text("SELECT", width/5, height/8);
    }
    if (scene == STAGEMENU) {
        fill(0, 127);
        rect(0, 0, width, height);
        fill(0);
        rect(width/4, height/4, width/2, height/2);
        fill(255, 255, 0);
        textSize(50);
        textAlign(CENTER, CENTER);
        if (isFocusStages) {
            text("STAGE MENU", width/2, height/3);
            for (int i = 0; i < stageMenuStrings.size(); i++) {
                if (i == selectedStageMenuNum) {
                    fill(255, 0, 0);
                } else {
                    fill(255);
                }
                text(stageMenuStrings.get(i), width/2, height/3 + 50*(i+1));
            }
        } else {
            text("JSON MENU", width/2, height/3);
            for (int i = 0; i < jsonMenuStrings.size(); i++) {
                if (i == selectedJsonMenuNum) {
                    fill(255, 0, 0);
                } else {
                    fill(255);
                }
                text(jsonMenuStrings.get(i), width/2, height/3 + 50*(i+1));
            }
        }
    }
    if (scene == EDIT) {
        fill(255);
        textSize(50);
        textAlign(CENTER, CENTER);
        text("EDIT", width/2, height/10);
        editingStage.display();
    }
    if (scene == EDITGAME || scene == EDITDEAD) {
        fill(255);
        textSize(50);
        textAlign(CENTER, CENTER);
        text("EDIT GAME", width/2, height/10);
        editingStage.display();
    }
    if (scene == EDITINFO) {
        fill(255);
        textSize(50);
        textAlign(CENTER, CENTER);
        text("EDIT INFO", width/2, height/10);
        editingStage.display();
    }
    if (scene == EDITDEAD) {
        fill(255);
        textSize(50);
        textAlign(CENTER, CENTER);
        text("MISS!", width/2, height/2);
        editingStage.display();
    }
    if (scene == ITEMINFO) {
        editingStage.display();
    }

    fill(255);
    textSize(20);
    text(scene, width-10, 10);

    if (leftMousePressed) {
        fill(0, 255, 0);
        ellipse(mouseX, mouseY, 10, 10);
    }
    if (rightMousePressed) {
        fill(0, 0, 255);
        ellipse(mouseX, mouseY, 10, 10);
    }

    mousePX = mouseX;
    mousePY = mouseY;
    keyCoolCount--;
}
