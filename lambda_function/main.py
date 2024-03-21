import boto3
from PIL import Image
import random

s3 = boto3.client('s3')


def image_resizer(filename, thumb_path):
    """Download image and resize it to 100x100 pixels
    Args:
        filename: Image file name
        thumb_path: Path to save the generated thumbnail"""

    with Image.open(filename) as img:
        img.thumbnail((100, 100))
        img.save(thumb_path)


def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    destination_bucket = "camesruiz-stori-thumbnails"

    try:
        filename = key.split("/")[-1]
        thumb_path = f'{filename.split(".")[0]}_thumb_{random.randint(1000, 9999)}.jpg'

        # Download image from S3
        s3.download_file(bucket, key, filename)

        # Create thumbnail
        image_resizer(filename, thumb_path)
        s3.upload_file(thumb_path, destination_bucket, thumb_path")

        return {
            'statusCode': 200,
            'body': 'Thumbnail generated successfully'
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': f'Error: {str(e)}'
        }
