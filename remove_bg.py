from PIL import Image
import os

def remove_background():
    input_path = "1000296482.png"
    output_path = os.path.join("assets", "anzor_ai_transparent.png")
    
    if not os.path.exists(input_path):
        print(f"Error: {input_path} not found.")
        return
        
    print(f"Opening {input_path}...")
    img = Image.open(input_path)
    rgba = img.convert("RGBA")
    
    datas = rgba.getdata()
    newData = []
    
    for item in datas:
        # scan for the dark background color threshold (R < 25, G < 25, B < 25)
        if item[0] < 25 and item[1] < 25 and item[2] < 25:
            # change to fully transparent white space
            newData.append((255, 255, 255, 0))
        else:
            newData.append(item)
            
    rgba.putdata(newData)
    
    # Ensure assets directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    print(f"Saving to {output_path}...")
    rgba.save(output_path, "PNG")
    print("Background removal complete!")

if __name__ == "__main__":
    remove_background()
