#!/usr/bin/env python3
"""
DynamoDB SDK Example for AWS Foundations Training
Demonstrates basic CRUD operations using boto3
"""

import boto3
from botocore.exceptions import ClientError
import json
from decimal import Decimal

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Music')

def add_song(artist, song_title, album, year, genre, **kwargs):
    """Add a song to the Music table"""
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
        print(f"✓ Added song: '{song_title}' by {artist}")
        return True
    except ClientError as e:
        print(f"✗ Error adding song: {e}")
        return False

def get_song(artist, song_title):
    """Get a specific song from the table"""
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
            print(f"Song '{song_title}' by {artist} not found")
            return None
    except ClientError as e:
        print(f"✗ Error getting song: {e}")
        return None

def query_songs_by_artist(artist):
    """Query all songs by a specific artist"""
    try:
        response = table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key('Artist').eq(artist)
        )
        return response['Items']
    except ClientError as e:
        print(f"✗ Error querying songs: {e}")
        return []

def update_song_rating(artist, song_title, rating):
    """Update the rating of a song"""
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
        print(f"✓ Updated rating for '{song_title}' by {artist}")
        return response['Attributes']
    except ClientError as e:
        print(f"✗ Error updating song: {e}")
        return None

def delete_song(artist, song_title):
    """Delete a song from the table"""
    try:
        table.delete_item(
            Key={
                'Artist': artist,
                'SongTitle': song_title
            }
        )
        print(f"✓ Deleted song: '{song_title}' by {artist}")
        return True
    except ClientError as e:
        print(f"✗ Error deleting song: {e}")
        return False

def scan_songs_by_genre(genre):
    """Scan for songs of a specific genre (less efficient than query)"""
    try:
        response = table.scan(
            FilterExpression=boto3.dynamodb.conditions.Attr('Genre').eq(genre)
        )
        return response['Items']
    except ClientError as e:
        print(f"✗ Error scanning songs: {e}")
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
        print()

def main():
    """Main demonstration function"""
    print("🎵 DynamoDB Music Library Demo")
    print("=" * 40)
    
    # Check if table exists
    try:
        table.load()
        print(f"✓ Connected to table: {table.table_name}")
        print(f"  Status: {table.table_status}")
        print()
    except ClientError:
        print("✗ Table 'Music' not found. Please create it first using AWS CLI.")
        return
    
    # Add sample songs
    print("1. Adding sample songs...")
    songs_to_add = [
        ("Pink Floyd", "Wish You Were Here", "Wish You Were Here", 1975, "Progressive Rock"),
        ("Led Zeppelin", "Stairway to Heaven", "Led Zeppelin IV", 1971, "Rock"),
        ("The Beatles", "Yesterday", "Help!", 1965, "Pop Rock"),
        ("Queen", "We Will Rock You", "News of the World", 1977, "Rock")
    ]
    
    for artist, title, album, year, genre in songs_to_add:
        add_song(artist, title, album, year, genre)
    
    print()
    
    # Query songs by artist
    print("2. Querying songs by The Beatles...")
    beatles_songs = query_songs_by_artist("The Beatles")
    for song in beatles_songs:
        print_song(song)
    
    # Get specific song
    print("3. Getting specific song...")
    song = get_song("Pink Floyd", "Wish You Were Here")
    print_song(song)
    
    # Update song rating
    print("4. Updating song rating...")
    updated_song = update_song_rating("Queen", "We Will Rock You", 5)
    if updated_song:
        print_song(updated_song)
    
    # Scan by genre
    print("5. Scanning for Rock songs...")
    rock_songs = scan_songs_by_genre("Rock")
    print(f"Found {len(rock_songs)} rock songs:")
    for song in rock_songs:
        print_song(song)
    
    # Clean up - delete one song
    print("6. Cleaning up - deleting one song...")
    delete_song("Led Zeppelin", "Stairway to Heaven")
    
    print("Demo completed! 🎉")

if __name__ == "__main__":
    main()
