import unittest
from unittest.mock import MagicMock, patch
import os
import sys
import random

parent_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.append(parent_dir)

from lambda_function.main import image_resizer, lambda_handler


class TestImageResizer(unittest.TestCase):

    @patch('lambda_function.main.s3')
    @patch('lambda_function.main.Image')
    def test_image_resizer(self, mock_Image, mock_s3):
        mock_img = MagicMock()
        mock_img.thumbnail.return_value = None
        mock_img.save.return_value = None
        mock_Image_open = MagicMock(return_value=mock_img)

        # Mock the PIL Image.open function
        with patch('lambda_function.main.Image.open', mock_Image_open):
            image_resizer('test/test_image.jpg', 'test_thumb.jpg')

        mock_Image.open('test_image.jpg')
        mock_img.thumbnail((100, 100))
        mock_img.save('test_thumb.jpg')

    @patch('lambda_function.main.boto3')
    def test_lambda_handler(self, mock_boto3):
        # Mock S3 client
        mock_s3 = MagicMock()
        mock_boto3.client.return_value = mock_s3
        mock_s3.download_file = MagicMock()
        mock_s3.upload_file = MagicMock()

        event = {
            'Records': [{
                's3': {
                    'bucket': {'name': 'test-bucket'},
                    'object': {'key': 'test_image.jpg'}
                }
            }]
        }
        context = MagicMock()

        # Mock random.randint to return a fixed value
        random.seed(123)
        expected_thumb_path = 'test_image_thumb_3761.jpg'

        # Call lambda_handler
        lambda_handler(event, context)

        mock_s3.download_file('test-bucket', 'test_image.jpg', 'test_image.jpg')
        image_resizer('test/test_image.jpg', expected_thumb_path)
        mock_s3.upload_file(expected_thumb_path, 'test-bucket', 'test_image_thumb_3761.jpg')


if __name__ == '__main__':
    unittest.main()

