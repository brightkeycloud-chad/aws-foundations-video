#!/usr/bin/env python3
"""
Step 5: Python SDK Demonstration
DynamoDB Table Operations Demo

This script demonstrates DynamoDB operations using the boto3 Python SDK.
It assumes the Music table already exists from previous steps.
"""

import boto3
from botocore.exceptions import ClientError
import json
from decimal import Decimal
import sys

# Colors for terminal output
class Colors:
    GREEN = '\033[0;32m'
    BLUE = '\033[0;34m'
    YELLOW = '\033[1;33m'
    RED = '\033[0;31m'
    NC = '\033[0m'  # No Color

def print_step(message):
    """Print step header"""
    print(f"{Colors.BLUE}{message}{Colors.NC}")
    print("=" * len(message))

def print_success(message):
    """Print success message"""
    print(f"{Colors.GREEN}✓ {message}{Colors.NC}")

def print_warning(message):
    """Print warning message"""
    print(f"{Colors.YELLOW}⚠️  {message}{Colors.NC}")

def print_error(message):
    """Print error message"""
    print(f"{Colors.RED}✗ {message}{Colors.NC}")

def print_info(message):
    """Print info message"""
    print(f"{Colors.BLUE}{message}{Colors.NC}")

# Initialize DynamoDB client
try:
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('Music')
    print_success("Connected to DynamoDB")
except Exception as e:
    print_error(f"Failed to connect to DynamoDB: {e}")
    sys.exit(1)

def check_table_exists():
    """Check if the Music table exists and is active"""
    try:
        table.load()
        if table.table_status == 'ACTIVE':
            print_success(f"Music table found and active")
            return True
        else:
            print_warning(f"Music table exists but status is: {table.table_status}")
            return False
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            print_error("Music table not found. Please run step1_create_table.sh first.")
            return False
        else:
            print_error(f"Error checking table: {e}")
            return False

def add_song_sdk(artist, song_title, album, year, genre, **kwargs):
    """Add a song using the SDK"""
    try:
        item = {
            'Artist': artist,
            'SongTitle': song_title,
            'Album': album,
            'Year': year,
            'Genre': genre
        }
        # Add any additional attributes
        item.update(kwargs)
        
        response = table.put_item(Item=item)
        print_success(f"Added: '{song_title}' by {artist}")
        return True
    except ClientError as e:
        print_error(f"Error adding song: {e}")
        return False

def get_song_sdk(artist, song_title):
    """Get a specific song using the SDK"""
    try:
        response = table.get_item(
            Key={
                'Artist': artist,
                'SongTitle': song_title
            }
        )
        if 'Item' in response:
            return response['Item']
        else:
            print_warning(f"Song '{song_title}' by {artist} not found")
            return None
    except ClientError as e:
        print_error(f"Error getting song: {e}")
        return None

def query_songs_by_artist_sdk(artist):
    """Query all songs by a specific artist using the SDK"""
    try:
        response = table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key('Artist').eq(artist)
        )
        return response['Items']
    except ClientError as e:
        print_error(f"Error querying songs: {e}")
        return []

def update_song_rating_sdk(artist, song_title, rating):
    """Update the rating of a song using the SDK"""
    try:
        response = table.update_item(
            Key={
                'Artist': artist,
                'SongTitle': song_title
            },
            UpdateExpression='SET Rating = :rating, LastUpdated = :timestamp',
            ExpressionAttributeValues={
                ':rating': Decimal(str(rating)),
                ':timestamp': '2024-01-15T10:30:00Z'
            },
            ReturnValues='ALL_NEW'
        )
        print_success(f"Updated rating for '{song_title}' by {artist}")
        return response['Attributes']
    except ClientError as e:
        print_error(f"Error updating song: {e}")
        return None

def scan_songs_by_genre_sdk(genre):
    """Scan for songs of a specific genre using the SDK"""
    try:
        response = table.scan(
            FilterExpression=boto3.dynamodb.conditions.Attr('Genre').eq(genre)
        )
        return response['Items']
    except ClientError as e:
        print_error(f"Error scanning songs: {e}")
        return []

def print_song(song):
    """Pretty print a song item"""
    if song:
        print(f"  🎵 {song['SongTitle']} by {song['Artist']}")
        print(f"     Album: {song.get('Album', 'Unknown')}")
        print(f"     Year: {song.get('Year', 'Unknown')}")
        print(f"     Genre: {song.get('Genre', 'Unknown')}")
        if 'Rating' in song:
            print(f"     Rating: {song['Rating']}/5")
        if 'PlayCount' in song:
            print(f"     Play Count: {song['PlayCount']}")
        if 'LastPlayed' in song:
            print(f"     Last Played: {song['LastPlayed']}")
        print()

def demonstrate_batch_operations():
    """Demonstrate batch operations"""
    print_info("Demonstrating batch operations...")
    
    # Batch write - add multiple items at once
    try:
        with table.batch_writer() as batch:
            batch.put_item(Item={
                'Artist': 'Pink Floyd',
                'SongTitle': 'Wish You Were Here',
                'Album': 'Wish You Were Here',
                'Year': 1975,
                'Genre': 'Progressive Rock'
            })
            batch.put_item(Item={
                'Artist': 'Pink Floyd',
                'SongTitle': 'Comfortably Numb',
                'Album': 'The Wall',
                'Year': 1979,
                'Genre': 'Progressive Rock'
            })
        
        print_success("Batch write completed - added 2 Pink Floyd songs")
        
        # Batch get - retrieve multiple items
        dynamodb_client = boto3.client('dynamodb')
        response = dynamodb_client.batch_get_item(
            RequestItems={
                'Music': {
                    'Keys': [
                        {
                            'Artist': {'S': 'Pink Floyd'},
                            'SongTitle': {'S': 'Wish You Were Here'}
                        },
                        {
                            'Artist': {'S': 'Pink Floyd'},
                            'SongTitle': {'S': 'Comfortably Numb'}
                        }
                    ]
                }
            }
        )
        
        print_success(f"Batch get completed - retrieved {len(response['Responses']['Music'])} items")
        
    except ClientError as e:
        print_error(f"Batch operation error: {e}")

def main():
    """Main demonstration function"""
    print_step("🎵 Step 5: Python SDK Demonstration")
    print()
    
    # Check if table exists
    if not check_table_exists():
        print_error("Cannot proceed without Music table. Please run previous steps first.")
        return
    
    print()
    
    # 1. Add a new song using SDK
    print_info("1. Adding a new song using Python SDK...")
    add_song_sdk("Led Zeppelin", "Stairway to Heaven", "Led Zeppelin IV", 1971, "Rock")
    print()
    
    # 2. Get specific song
    print_info("2. Getting specific song using SDK...")
    song = get_song_sdk("Led Zeppelin", "Stairway to Heaven")
    if song:
        print("Retrieved song:")
        print_song(song)
    
    # 3. Query songs by artist
    print_info("3. Querying all songs by The Beatles using SDK...")
    beatles_songs = query_songs_by_artist_sdk("The Beatles")
    print(f"Found {len(beatles_songs)} Beatles songs:")
    for song in beatles_songs:
        print_song(song)
    
    # 4. Update song rating
    print_info("4. Updating song rating using SDK...")
    updated_song = update_song_rating_sdk("Led Zeppelin", "Stairway to Heaven", 5)
    if updated_song:
        print("Updated song:")
        print_song(updated_song)
    
    # 5. Scan by genre
    print_info("5. Scanning for Rock songs using SDK...")
    rock_songs = scan_songs_by_genre_sdk("Rock")
    print(f"Found {len(rock_songs)} rock songs:")
    for song in rock_songs:
        print_song(song)
    
    # 6. Demonstrate batch operations
    print_info("6. Batch operations demonstration...")
    demonstrate_batch_operations()
    print()
    
    # 7. Show final table state
    print_info("7. Final table state...")
    try:
        response = table.scan()
        items = response['Items']
        print(f"Total items in table: {len(items)}")
        print("\nAll songs in the Music table:")
        for song in sorted(items, key=lambda x: (x['Artist'], x['SongTitle'])):
            print_song(song)
    except ClientError as e:
        print_error(f"Error scanning table: {e}")
    
    print_success("Python SDK demonstration completed! 🎉")
    print()
    print("Key SDK Features Demonstrated:")
    print("  ✓ Resource vs Client interfaces")
    print("  ✓ Pythonic attribute access")
    print("  ✓ Automatic type conversion")
    print("  ✓ Exception handling")
    print("  ✓ Batch operations")
    print("  ✓ Condition expressions")
    print()
    print("SDK Advantages over CLI:")
    print("  • More intuitive Python syntax")
    print("  • Better error handling")
    print("  • Type safety with proper data types")
    print("  • Integration with Python applications")
    print("  • Batch operations for efficiency")

if __name__ == "__main__":
    main()
