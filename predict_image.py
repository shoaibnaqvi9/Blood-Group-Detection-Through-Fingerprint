import tensorflow as tf
from tensorflow.keras.preprocessing.image import img_to_array, load_img
import numpy as np
import os
import shutil
model = tf.keras.models.load_model('cnn_model_updated.h5')
blood_group_labels = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']

def preprocess_image(image_path):
    image = load_img(image_path, target_size=(32, 32))
    image = img_to_array(image)
    image = image / 255.0  # Normalize the image
    image = np.expand_dims(image, axis=0)  # Expand dimensions to match model input
    return image

def save_incorrect_classification(image_path, true_label):
    base_dir = 'dataset/incorrect_classifications'
    label_dir = os.path.join(base_dir, true_label)
    
    if not os.path.exists(label_dir):
        os.makedirs(label_dir)
    
    # Save the image with its original filename in the respective label directory
    image_name = os.path.basename(image_path)
    incorrect_image_path = os.path.join(label_dir, image_name)
    
    # Use shutil to move the file to the respective folder
    shutil.move(image_path, incorrect_image_path)

# Predict function to classify fingerprint and blood group
def predict_image(image_path):
    image = preprocess_image(image_path)
    
    # Predict using the loaded model
    predictions = model.predict(image)
    
    if isinstance(predictions, list) and len(predictions) > 1:
        # Multi-output model case
        fingerprint_confidence = predictions[0][0]  # Binary output for fingerprint
        blood_group_prediction = np.argmax(predictions[1], axis=-1)
        
        if fingerprint_confidence > 0.5:  # Threshold for fingerprint detection
            blood_group = blood_group_labels[blood_group_prediction[0]]
            print("Fingerprint detected.")
            print(f"Predicted blood group: {blood_group}")
            return True, blood_group  # Return prediction result
        else:
            print("No fingerprint detected.")
            return False, None
    else:
        # Single output model case (assumes blood group classification only)
        blood_group_prediction = np.argmax(predictions, axis=-1)
        blood_group = blood_group_labels[blood_group_prediction[0]]
        print("Model only supports blood group classification.")
        print(f"Predicted blood group: {blood_group}")
        return False, blood_group

def handle_user_feedback(image_path, true_blood_group):
    save_incorrect_classification(image_path, true_blood_group)
    print("Incorrect classification saved. Thank you for your feedback!")

image_path = r"C:\FYPproject\dataset\incorrect_classifications\A-\cluster_1_40.bmp"
print("Starting prediction...")
is_fingerprint, predicted_blood_group = predict_image(image_path)
print("Prediction complete.")

if not is_fingerprint:
    user_input = input(f"Is the predicted blood group '{predicted_blood_group}' correct? (y/n): ")
    if user_input.lower() == 'n':
        true_blood_group = input("Please enter the correct blood group: ")
        handle_user_feedback(image_path, true_blood_group)
else:
    print("Asking for user confirmation.")
    user_input = input(f"Is the predicted blood group '{predicted_blood_group}' correct? (y/n): ")
    if user_input.lower() == 'n':
        true_blood_group = input("Please enter the correct blood group: ")
        handle_user_feedback(image_path, true_blood_group)
